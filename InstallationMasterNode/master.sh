#!/usr/bin/env bash
# Fresh Ubuntu Server EC2 setup. Run with sudo bash.
set -Eeuo pipefail
trap 'echo "ERROR at line $LINENO. Fix the reported problem before continuing." >&2' ERR
export DEBIAN_FRONTEND=noninteractive
K8S_MINOR=1.34
K8S_VERSION=1.34.5
K8S_PACKAGE=1.34.5-1.1
CRI_SOCKET=unix:///run/containerd/containerd.sock
die() { echo "ERROR: $*" >&2; exit 1; }

preflight() {
  [[ $EUID -eq 0 ]] || die 'Run this script with sudo bash.'
  # shellcheck disable=SC1091
  source /etc/os-release
  [[ $ID == ubuntu ]] || die "Use Ubuntu Server. Detected: ${PRETTY_NAME:-unknown OS}."
  command -v apt-get >/dev/null || die 'This Ubuntu installation requires apt-get.'
  [[ -d /run/systemd/system ]] || die 'Run on an Ubuntu instance booted with systemd.'
  echo "Operating system: $PRETTY_NAME"
  [[ $(dpkg --print-architecture) == amd64 ]] || die 'Use an x86_64 instance, such as t3.medium.'
  [[ $(nproc) -ge 2 ]] || die 'At least 2 vCPUs are required.'
  [[ ! -e /etc/kubernetes/kubelet.conf && ! -e /etc/kubernetes/admin.conf && ! -d /var/lib/etcd/member ]] ||
    die 'Existing cluster state found. These scripts are for new nodes, not upgrades or resets.'
  NODE_IP=${NODE_IP:-$(ip -4 route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if($i=="src") {print $(i+1); exit}}')}
  [[ -n $NODE_IP ]] || die 'Could not detect the private IPv4 address. Set NODE_IP explicitly.'
  ip -o -4 addr show | awk '{print $4}' | cut -d/ -f1 | grep -Fxq "$NODE_IP" ||
    die 'NODE_IP must be an IPv4 address assigned to this instance.'
  echo "Using node private IP: $NODE_IP"
}

prepare_host() {
  swapoff -a
  cp -an /etc/fstab /etc/fstab.before-kubernetes
  sed -i -E '/^[[:space:]]*#/! { /[[:space:]]swap[[:space:]]/ s/^/# Kubernetes: /; }' /etc/fstab
  # Fresh EC2 Ubuntu normally has no swap. Disable persistent systemd swap units too.
  while read -r unit _; do
    [[ $unit == *.swap ]] && systemctl mask "$unit"
  done < <(systemctl list-units --all --type=swap --no-legend --plain)
  cat > /etc/modules-load.d/kubernetes.conf <<'EOF'
overlay
br_netfilter
EOF
  modprobe overlay
  modprobe br_netfilter
  cat > /etc/sysctl.d/99-kubernetes.conf <<'EOF'
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF
  sysctl --system
  apt-get -o DPkg::Lock::Timeout=300 update
  apt-get -o DPkg::Lock::Timeout=300 install -y ca-certificates curl gpg containerd iptables conntrack socat
  mkdir -p /etc/containerd
  [[ ! -e /etc/containerd/config.toml ]] || cp -an /etc/containerd/config.toml /etc/containerd/config.toml.before-kubernetes
  containerd config default > /etc/containerd/config.toml
  # Works with both containerd 1.x and 2.x default configuration layouts.
  sed -i -E 's/SystemdCgroup[[:space:]]*=[[:space:]]*false/SystemdCgroup = true/g' /etc/containerd/config.toml
  grep -Eq 'SystemdCgroup[[:space:]]*=[[:space:]]*true' /etc/containerd/config.toml || die 'Cannot configure containerd systemd cgroups.'
  systemctl enable containerd
  systemctl restart containerd
  systemctl is-active --quiet containerd
  ctr plugins ls | awk '
    $NF == "ok" && $2 == "cri" {runtime=1; images=1}
    $NF == "ok" && $1 == "io.containerd.cri.v1" && $2 == "runtime" {runtime=1}
    $NF == "ok" && $1 == "io.containerd.cri.v1" && $2 == "images" {images=1}
    END {exit !(runtime && images)}' ||
    die 'containerd CRI plugin is not healthy.'
  install -m 0755 -d /etc/apt/keyrings
  curl --retry 3 -fsSL "https://pkgs.k8s.io/core:/stable:/v${K8S_MINOR}/deb/Release.key" |
    gpg --batch --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  chmod 0644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_MINOR}/deb/ /" > /etc/apt/sources.list.d/kubernetes.list
  apt-get -o DPkg::Lock::Timeout=300 update
}

install_kubernetes() {
  local package
  for package in kubelet kubeadm kubectl; do
    if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q 'install ok installed'; then
      [[ $(dpkg-query -W -f='${Version}' "$package") == "$K8S_PACKAGE" ]] ||
        die "$package already has another version. Start with a fresh instance."
    fi
  done
  apt-get -o DPkg::Lock::Timeout=300 install -y "kubelet=$K8S_PACKAGE" "kubeadm=$K8S_PACKAGE" "kubectl=$K8S_PACKAGE"
  apt-mark hold kubelet kubeadm kubectl
  echo "KUBELET_EXTRA_ARGS=--node-ip=$NODE_IP" > /etc/default/kubelet
  systemctl enable kubelet
  cat > /etc/crictl.yaml <<EOF
runtime-endpoint: $CRI_SOCKET
image-endpoint: $CRI_SOCKET
timeout: 10
EOF
  echo "Installed Kubernetes $K8S_VERSION (package $K8S_PACKAGE)"
}


[[ $# -eq 0 ]] || die 'Usage: sudo bash master.sh'
CALICO_VERSION=v3.31.0
POD_CIDR=${POD_CIDR:-192.168.0.0/16}
SERVICE_CIDR=${SERVICE_CIDR:-10.96.0.0/12}
preflight
prepare_host
install_kubernetes
install -d -m 0700 /root/k8s-bootstrap
# Download networking manifests before initializing the cluster.
for manifest in operator-crds tigera-operator; do
  curl --retry 3 -fsSL "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/${manifest}.yaml" \
    -o "/root/k8s-bootstrap/${manifest}.yaml"
done
cat > /root/k8s-bootstrap/calico-installation.yaml <<EOF
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  variant: Calico
  calicoNetwork:
    bgp: Disabled
    nodeAddressAutodetectionV4:
      kubernetes: NodeInternalIP
    ipPools:
      - cidr: $POD_CIDR
        blockSize: 26
        encapsulation: VXLAN
        natOutgoing: Enabled
        nodeSelector: all()
EOF
kubeadm init --kubernetes-version="v$K8S_VERSION" \
  --apiserver-advertise-address="$NODE_IP" \
  --control-plane-endpoint="${NODE_IP}:6443" \
  --pod-network-cidr="$POD_CIDR" --service-cidr="$SERVICE_CIDR" \
  --cri-socket="$CRI_SOCKET" --skip-phases=show-join-command --skip-token-print
export KUBECONFIG=/etc/kubernetes/admin.conf
admin_user=${SUDO_USER:-root}
admin_home=$(getent passwd "$admin_user" | cut -d: -f6)
admin_group=$(id -gn "$admin_user")
install -d -m 0700 -o "$admin_user" -g "$admin_group" "$admin_home/.kube"
[[ ! -e $admin_home/.kube/config ]] || cp -an "$admin_home/.kube/config" "$admin_home/.kube/config.before-kubernetes"
install -m 0600 -o "$admin_user" -g "$admin_group" /etc/kubernetes/admin.conf "$admin_home/.kube/config"
kubectl apply --server-side -f /root/k8s-bootstrap/operator-crds.yaml
kubectl wait --for=condition=Established crd/installations.operator.tigera.io --timeout=120s
kubectl apply --server-side -f /root/k8s-bootstrap/tigera-operator.yaml
kubectl apply -f /root/k8s-bootstrap/calico-installation.yaml
kubectl wait --for=create daemonset/calico-node -n calico-system --timeout=300s
kubectl rollout status daemonset/calico-node -n calico-system --timeout=300s
kubectl wait --for=condition=Ready nodes --all --timeout=300s
echo 'Master setup complete. Follow README.md for the remaining steps.'
