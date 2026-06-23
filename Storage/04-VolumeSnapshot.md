# VolumeSnapshot – Kubernetes Mental Model

A VolumeSnapshot is a **point-in-time copy of a PersistentVolumeClaim (PVC)**.

It is used for **backup, restore, and cloning storage state**.

Think of it as:
- PVC = active storage
- VolumeSnapshot = frozen copy of PVC at a moment in time
- Restore = new PVC created from snapshot

---

# Full YAML Structure

```text
VolumeSnapshot
├── apiVersion: snapshot.storage.k8s.io/v1
├── kind: VolumeSnapshot
├── metadata
│   ├── name: my-snapshot
│   └── namespace: app-space
│
└── spec
    ├── volumeSnapshotClassName: csi-snapshot-class
    │
    └── source
        └── persistentVolumeClaimName: my-pvc
