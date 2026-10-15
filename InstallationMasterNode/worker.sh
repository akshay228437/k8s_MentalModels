#!/usr/bin/env bash
# Fresh Ubuntu 24.04 EC2 setup. Run with sudo bash.
set -Eeuo pipefail
trap 'echo "ERROR at line $LINENO. Fix the reported problem before continuing." >&2' ERR
export DEBIAN_FRONTEND=noninteractive
K8S_MINOR=1.34
CRI_SOCKET=unix:///run/containerd/containerd.sock
die() { echo "ERROR: $*" >&2; exit 1; }

preflight() {
  [[ $EUID -eq 0 ]] || die 'Run this script with sudo bash.'
  # shellcheck disable=SC1091
  source /etc/os-release
  [[ $ID == ubuntu && $VERSION_ID == 24.04 ]] || die 'Use a fresh Ubuntu Server 24.04 LTS instance.'
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
  apt-get -o DPkg::Lock::Timeout=300 install -y ca-certificates curl gpg containerd
  mkdir -p /etc/containerd
  [[ ! -e /etc/containerd/config.toml ]] || cp -an /etc/containerd/config.toml /etc/containerd/config.toml.before-kubernetes
  containerd config default > /etc/containerd/config.toml
  # Works with both containerd 1.x and 2.x default configuration layouts.
  sed -i -E 's/SystemdCgroup[[:space:]]*=[[:space:]]*false/SystemdCgroup = true/g' /etc/containerd/config.toml
  grep -Eq 'SystemdCgroup[[:space:]]*=[[:space:]]*true' /etc/containerd/config.toml || die 'Cannot configure containerd systemd cgroups.'
  systemctl enable containerd
  systemctl restart containerd
  systemctl is-active --quiet containerd
  ctr plugins ls | awk '($2 == "cri" || ($1 == "io.containerd.cri.v1" && $2 == "runtime")) && $NF == "ok" {found=1} END {exit !found}' ||
    die 'containerd CRI plugin is not healthy.'
  install -m 0755 -d /etc/apt/keyrings
  curl --retry 3 -fsSL "https://pkgs.k8s.io/core:/stable:/v${K8S_MINOR}/deb/Release.key" |
    gpg --batch --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  chmod 0644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_MINOR}/deb/ /" > /etc/apt/sources.list.d/kubernetes.list
  apt-get -o DPkg::Lock::Timeout=300 update
}

install_kubernetes() {
  local available candidate
  available=$(apt-cache madison kubeadm | awk '{print $3}')
  if [[ -z $K8S_VERSION ]]; then
    # The repository is restricted to one minor; choose its highest patch.
    candidate=$(printf '%s\n' "$available" | sort -V | tail -n1)
    [[ -n $candidate ]] || die 'No Kubernetes packages found.'
    K8S_VERSION=${candidate%%-*}
  fi
  [[ $K8S_VERSION =~ ^1\.34\.[0-9]+$ ]] || die 'This bundle supports Kubernetes 1.34.x only.'
  K8S_PACKAGE=$(printf '%s\n' "$available" | awk -v v="$K8S_VERSION" 'index($0,v "-")==1 {print; exit}')
  [[ -n $K8S_PACKAGE ]] || die "Kubernetes $K8S_VERSION is unavailable in the repository."
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


[[ $# -eq 1 ]] || die 'Usage: sudo bash worker.sh 1.34.PATCH (copy the exact version printed by master.sh)'
K8S_VERSION=$1
[[ $K8S_VERSION =~ ^1\.34\.[0-9]+$ ]] || die 'Supply the exact 1.34.x patch printed by master.sh.'
preflight
prepare_host
install_kubernetes
echo
echo 'Worker prepared. Now paste the sudo kubeadm join command from the master.'
echo 'The kubelet may restart until you join; that is expected.'
