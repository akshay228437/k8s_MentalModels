# RoleBinding – Kubernetes Mental Model

A RoleBinding **grants a Role to a user, group, or service account within a namespace**.

It is the “connector” between:
- **Role → what permissions exist**
- **Subject → who gets them**

Think of it as:
- Role = permissions
- RoleBinding = assignment of permissions (namespace-scoped)
- Subject = identity (user/group/serviceAccount)

---

# Full YAML Structure

```text
RoleBinding
├── apiVersion: rbac.authorization.k8s.io/v1
├── kind: RoleBinding
├── metadata
│   ├── name: read-pods-binding
│   └── namespace: app-space
│
├── subjects[]
│   ├── kind: User | Group | ServiceAccount
│   ├── name: dev-user
│   ├── namespace: app-space (only for ServiceAccount)
│   └── apiGroup: rbac.authorization.k8s.io
│
└── roleRef
    ├── apiGroup: rbac.authorization.k8s.io
    ├── kind: Role
    └── name: pod-reader
