# ReplicaSet – Kubernetes Mental Model

A ReplicaSet ensures a fixed number of identical Pods are always running.

---

# Full YAML Structure

```text
ReplicaSet
├── apiVersion: apps/v1
├── kind: ReplicaSet
├── metadata
│   ├── name: my-replicaset
│   ├── namespace: default
│   ├── labels
│   │   └── app: nginx
│   └── annotations
│       └── description: maintains nginx pods
└── spec
    ├── replicas: 3
    ├── selector
    │   └── matchLabels
    │       └── app: nginx
    └── template
        ├── metadata
        │   └── labels
        │       └── app: nginx
        └── spec
            ├── containers[]
            │   ├── name: nginx
            │   ├── image: nginx:1.25
            │   ├── ports
            │   │   └── containerPort: 80
            │   ├── env
            │   │   └── ENV: prod
            │   └── resources
            │       ├── requests
            │       │   ├── cpu: 100m
            │       │   └── memory: 128Mi
            │       └── limits
            │           ├── cpu: 500m
            │           └── memory: 512Mi
            ├── volumes
            │   └── (optional)
            └── scheduling
                ├── nodeSelector
                ├── tolerations
                └── affinity
