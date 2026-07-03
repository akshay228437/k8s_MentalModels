# Role – Kubernetes Mental Model

A Role defines **a set of permissions inside a specific namespace**.

It is used for **fine-grained access control** in Kubernetes (RBAC).

Think of it as:
- Role = what actions are allowed
- Namespace = where those actions are allowed
- RoleBinding = who gets those permissions

---

# Full YAML Structure

```text
Role
├── apiVersion: rbac.authorization.k8s.io/v1
├── kind: Role
├── metadata
│   ├── name: pod-reader
│   └── namespace: app-space
│
└── rules[]
    ├── apiGroups[]
    │   └── "" (core API group)
    │
    ├── resources[]
    │   ├── pods
    │   ├── services
    │   └── configmaps
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
    │   └── my-pod
    │
    └── nonResourceURLs[] (optional)
        └── /healthz
