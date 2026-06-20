# DaemonSet – Kubernetes Mental Model

---

# Full YAML Structure

```text
DaemonSet
├── apiVersion: apps/v1
├── kind: DaemonSet
├── metadata
│   ├── name: my-daemonset
│   ├── namespace: kube-system
│   ├── labels
│   │   └── app: node-agent
│   └── annotations
│       └── description: runs one pod per node
└── spec
    ├── selector
    │   └── matchLabels
    │       └── app: node-agent
    ├── updateStrategy
    │   └── type: RollingUpdate
    └── template
        ├── metadata
        │   └── labels
        │       └── app: node-agent
        └── spec
            ├── containers[]
            │   ├── name: node-agent
            │   ├── image: fluentd:latest
            │   ├── ports
            │   │   └── containerPort: 24224
            │   ├── env
            │   │   └── LOG_LEVEL: info
            │   └── resources
            │       ├── requests
            │       │   ├── cpu: 100m
            │       │   └── memory: 128Mi
            │       └── limits
            │           ├── cpu: 200m
            │           └── memory: 256Mi
            ├── tolerations
            │   └── key: node-role.kubernetes.io/master
            │       operator: Exists
            │       effect: NoSchedule
            └── scheduling
                ├── nodeSelector
                └── affinity
