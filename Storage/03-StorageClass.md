# StorageClass – Kubernetes Mental Model

A StorageClass defines **how storage is dynamically provisioned** in Kubernetes.

Instead of manually creating PVs, StorageClass allows Kubernetes to **create PVs on demand** when a PVC is created.

Think of it as:
- StorageClass = blueprint / recipe
- PVC = request
- PV = actual storage created dynamically

---

# Full YAML Structure

```text
StorageClass
├── apiVersion: storage.k8s.io/v1
├── kind: StorageClass
├── metadata
│   ├── name: fast-storage
│   └── annotations
│       └── storageclass.kubernetes.io/is-default-class: "false"
│
├── provisioner: ebs.csi.aws.com
│
├── parameters
│   ├── type: gp3
│   ├── fsType: ext4
│   └── encrypted: "true"
│
├── reclaimPolicy: Delete | Retain
│
├── volumeBindingMode: Immediate | WaitForFirstConsumer
│
├── allowVolumeExpansion: true | false
│
└── mountOptions[]
    ├── debug
    └── nfsvers=4.1
