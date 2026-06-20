# NetworkPolicy – Kubernetes Mental Model

NetworkPolicy defines **rules for controlling traffic between Pods and namespaces**.

By default, Kubernetes allows all traffic. NetworkPolicy is used to enforce **Zero Trust networking**.

---

# Full YAML Structure

```text
NetworkPolicy
├── apiVersion: networking.k8s.io/v1
├── kind: NetworkPolicy
├── metadata
│   ├── name: my-network-policy
│   ├── namespace: secure-project
│   └── labels
│       └── app: secure-app
└── spec
    ├── podSelector
    │   └── matchLabels
    │       └── app: backend
    │
    ├── policyTypes[]
    │   ├── Ingress
    │   └── Egress
    │
    ├── ingress[]
    │   ├── from[]
    │   │   ├── podSelector
    │   │   │   └── matchLabels
    │   │   │       └── app: frontend
    │   │   ├── namespaceSelector
    │   │   │   └── matchLabels
    │   │   │       └── env: prod
    │   │   └── ipBlock
    │   │       ├── cidr: 10.0.0.0/24
    │   │       └── except[]
    │   │           └── 10.0.0.5/32
    │   │
    │   └── ports[]
    │       ├── protocol: TCP
    │       └── port: 80
    │
    └── egress[]
        ├── to[]
        │   ├── podSelector
        │   │   └── matchLabels
        │   │       └── app: db
        │   ├── namespaceSelector
        │   │   └── matchLabels
        │   │       └── env: prod
        │   └── ipBlock
        │       └── cidr: 0.0.0.0/0
        │
        └── ports[]
            ├── protocol: TCP
            └── port: 5432
