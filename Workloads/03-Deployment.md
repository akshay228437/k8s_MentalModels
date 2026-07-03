# Deployment – Kubernetes Mental Model

A Deployment manages ReplicaSets and provides **rolling updates, rollback, and version control for Pods**.

---

# Full YAML Structure

```text
Deployment
├── apiVersion: apps/v1
├── kind: Deployment
├── metadata
│   ├── name: my-deployment
│   ├── namespace: default
│   ├── labels
│   │   └── app: nginx
│   └── annotations
│       └── description: nginx deployment
└── spec
    ├── replicas: 3
    ├── selector
    │   └── matchLabels
    │       └── app: nginx
    ├── strategy
    │   ├── type: RollingUpdate
    │   └── rollingUpdate
    │       ├── maxSurge: 1
    │       └── maxUnavailable: 1
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
