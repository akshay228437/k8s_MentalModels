# ServiceAccount – Kubernetes Mental Model

ServiceAccount provides an **identity for Pods to access the Kubernetes API securely**.

It replaces using user credentials inside Pods and enables **controlled access via RBAC**.

---

# Full YAML Structure

```text
ServiceAccount
├── apiVersion: v1
├── kind: ServiceAccount
├── metadata
│   ├── name: my-serviceaccount
│   ├── namespace: default
│   ├── labels
│   │   └── app: backend
│   └── annotations
│       └── description: pod identity for api access
├── automountServiceAccountToken: true
└── secrets[]
    └── name: my-serviceaccount-token
