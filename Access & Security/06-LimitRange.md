# LimitRange – Kubernetes Mental Model

A LimitRange defines **default, minimum, and maximum resource constraints for individual Pods/Containers inside a namespace**.

It controls **how much each workload can request or consume**, unlike ResourceQuota which limits the namespace as a whole.

Think of it as:
- ResourceQuota = total namespace budget
- LimitRange = per-Pod / per-Container guardrails

---

# Full YAML Structure

```text
LimitRange
├── apiVersion: v1
├── kind: LimitRange
├── metadata
│   ├── name: cpu-memory-limits
│   └── namespace: app-space
│
└── spec
    └── limits[]
        ├── type: Pod | Container | PersistentVolumeClaim
        │
        ├── max
        │   ├── cpu: "2"
        │   └── memory: 2Gi
        │
        ├── min
        │   ├── cpu: "100m"
        │   └── memory: 128Mi
        │
        ├── default
        │   ├── cpu: "500m"
        │   └── memory: 512Mi
        │
        ├── defaultRequest
        │   ├── cpu: "200m"
        │   └── memory: 256Mi
        │
        └── maxLimitRequestRatio
            ├── cpu: "4"
            └── memory: "2"
