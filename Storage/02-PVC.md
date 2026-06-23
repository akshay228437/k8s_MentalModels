# PersistentVolumeClaim (PVC) – Kubernetes Mental Model

A PersistentVolumeClaim (PVC) is a **namespace-scoped request for storage**.

It is how Pods ask for storage without knowing the underlying implementation.

Think of it as:
- PV = actual storage
- PVC = request for storage
- Pod = consumer of PVC

PVC is **bound to a PV** that satisfies its requirements.

---

# Full YAML Structure

```text
PersistentVolumeClaim
├── apiVersion: v1
├── kind: PersistentVolumeClaim
├── metadata
│   ├── name: my-pvc
│   └── namespace: app-space
│
└── spec
    ├── accessModes[]
    │   ├── ReadWriteOnce (RWO)
    │   ├── ReadOnlyMany (ROX)
    │   └── ReadWriteMany (RWX)
    │
    ├── resources
    │   └── requests
    │       └── storage: 10Gi
    │
    ├── storageClassName: fast-storage
    │
    ├── volumeMode: Filesystem | Block
    │
    ├── volumeName: my-pv   (optional direct binding)
    │
    ├── selector
    │   └── matchLabels
    │       └── type: fast-ssd
    │
    └── dataSource
        ├── kind: PersistentVolumeClaim | VolumeSnapshot
        └── name: snapshot-1
