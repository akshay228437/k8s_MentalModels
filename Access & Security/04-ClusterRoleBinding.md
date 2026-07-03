# ClusterRoleBinding – Kubernetes Mental Model

A ClusterRoleBinding grants a **ClusterRole to a user, group, or service account across the entire cluster**.

It is the cluster-wide version of a RoleBinding.

Think of it as:
- ClusterRole = cluster-wide permissions
- ClusterRoleBinding = assignment of those permissions
- Subject = who gets access

---

# Full YAML Structure

```text
ClusterRoleBinding
├── apiVersion: rbac.authorization.k8s.io/v1
├── kind: ClusterRoleBinding
├── metadata
│   ├── name: cluster-admin-binding
│
├── subjects[]
│   ├── kind: User | Group | ServiceAccount
│   ├── name: admin-user
│   ├── namespace: kube-system (only for ServiceAccount)
│   └── apiGroup: rbac.authorization.k8s.io
│
└── roleRef
    ├── apiGroup: rbac.authorization.k8s.io
    ├── kind: ClusterRole
    └── name: cluster-admin
