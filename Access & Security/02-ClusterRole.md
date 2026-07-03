# ClusterRole – Kubernetes Mental Model

A ClusterRole defines **permissions across the entire cluster**, not limited to a single namespace.

It is used for:
- cluster-wide resources (nodes, persistentvolumes)
- cross-namespace access (pods, services, etc.)
- controllers and system components

Think of it as:
- Role = namespace-level permissions
- ClusterRole = cluster-wide permissions
- ClusterRoleBinding = assigns these permissions to users/groups/service accounts

---

# Full YAML Structure

```text
ClusterRole
├── apiVersion: rbac.authorization.k8s.io/v1
├── kind: ClusterRole
├── metadata
│   ├── name: cluster-admin-reader
│
└── rules[]
    ├── apiGroups[]
    │   ├── "" (core API group)
    │   └── apps
    │
    ├── resources[]
    │   ├── pods
    │   ├── services
    │   ├── nodes
    │   ├── persistentvolumes
    │   └── deployments
    │
    ├── verbs[]
    │   ├── get
    │   ├── list
    │   ├── watch
    │   ├── create
    │   ├── update
    │   └── delete
    │
    ├── resourceNames[] (optional)
    │   └── specific-resource
    │
    └── nonResourceURLs[] (optional)
        ├── /healthz
        └── /metrics
