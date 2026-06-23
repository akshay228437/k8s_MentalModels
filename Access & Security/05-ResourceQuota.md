# ResourceQuota – Kubernetes Mental Model

A ResourceQuota defines **hard limits on resource usage within a namespace**.

It ensures a namespace cannot consume more than its allocated share of cluster resources.

Think of it as:
- Namespace = tenant/project space
- ResourceQuota = budget limit for that namespace
- Enforced at creation time

---

# Full YAML Structure

```text
ResourceQuota
├── apiVersion: v1
├── kind: ResourceQuota
├── metadata
│   ├── name: compute-quota
│   └── namespace: app-space
│
└── spec
    ├── hard
    │   ├── pods: "10"
    │   ├── requests.cpu: "4"
    │   ├── requests.memory: 8Gi
    │   ├── limits.cpu: "8"
    │   ├── limits.memory: 16Gi
    │   ├── persistentvolumeclaims: "5"
    │   ├── services: "10"
    │   └── requests.storage: 100Gi
    │
    └── scopeSelector (optional)
        └── matchExpressions[]
            ├── scopeName: PriorityClass
            ├── operator: In
            └── values[]
                └── high
