# HorizontalPodAutoscaler (HPA) – Kubernetes Mental Model

HorizontalPodAutoscaler (HPA) automatically **scales the number of Pods in a workload** based on observed metrics such as CPU, memory, or custom/external metrics.

It helps applications handle changing workloads without manual intervention.

---

# Full YAML Structure

```text
HorizontalPodAutoscaler
├── apiVersion: autoscaling/v2
├── kind: HorizontalPodAutoscaler
├── metadata
│   ├── name: my-hpa
│   ├── namespace: default
│   └── labels
│       └── app: my-app
└── spec
    ├── scaleTargetRef
    │   ├── apiVersion: apps/v1
    │   ├── kind: Deployment
    │   └── name: my-app
    │
    ├── minReplicas: 2
    ├── maxReplicas: 10
    │
    ├── metrics[]
    │   ├── type: Resource
    │   ├── resource
    │   │   ├── name: cpu
    │   │   └── target
    │   │       ├── type: Utilization
    │   │       └── averageUtilization: 70
    │   │
    │   ├── type: Pods
    │   │   └── pods
    │   │       ├── metric
    │   │       │   └── name: requests_per_second
    │   │       └── target
    │   │           ├── type: AverageValue
    │   │           └── averageValue: 100
    │   │
    │   ├── type: Object
    │   │   └── object
    │   │       ├── describedObject
    │   │       │   ├── apiVersion
    │   │       │   ├── kind
    │   │       │   └── name
    │   │       ├── metric
    │   │       │   └── name
    │   │       └── target
    │   │           ├── type
    │   │           └── value
    │   │
    │   └── type: External
    │       └── external
    │           ├── metric
    │           │   ├── name
    │           │   └── selector
    │           │       └── matchLabels
    │           └── target
    │               ├── type
    │               └── value
    │
    └── behavior
        ├── scaleUp
        │   ├── stabilizationWindowSeconds
        │   ├── selectPolicy
        │   └── policies[]
        │       ├── type: Percent | Pods
        │       ├── value
        │       └── periodSeconds
        │
        └── scaleDown
            ├── stabilizationWindowSeconds
            ├── selectPolicy
            └── policies[]
                ├── type: Percent | Pods
                ├── value
                └── periodSeconds
```
