# VerticalPodAutoscaler (VPA) – Kubernetes Mental Model

VerticalPodAutoscaler (VPA) automatically **adjusts CPU and memory requests/limits** of Pods based on historical resource usage.

Unlike HPA, VPA **scales resources inside a Pod**, not the number of Pods.

---

# Full YAML Structure

```text
VerticalPodAutoscaler
├── apiVersion: autoscaling.k8s.io/v1
├── kind: VerticalPodAutoscaler
├── metadata
│   ├── name: my-vpa
│   ├── namespace: default
│   └── labels
│       └── app: my-app
└── spec
    ├── targetRef
    │   ├── apiVersion: apps/v1
    │   ├── kind: Deployment
    │   └── name: my-app
    │
    ├── updatePolicy
    │   └── updateMode
    │       ├── "Off"
    │       ├── "Initial"
    │       ├── "Recreate"
    │       └── "Auto"
    │
    └── resourcePolicy
        └── containerPolicies[]
            ├── containerName
            ├── mode
            │   ├── "Auto"
            │   └── "Off"
            ├── minAllowed
            │   ├── cpu
            │   └── memory
            ├── maxAllowed
            │   ├── cpu
            │   └── memory
            └── controlledResources[]
                ├── cpu
                └── memory
```
