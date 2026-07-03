# Gateway – Kubernetes Gateway API Mental Model

Gateway defines **how traffic enters the cluster at L4/L7 level** in the Kubernetes Gateway API.

It is a **modern replacement for Ingress (more structured, extensible, and multi-protocol aware)**.

---

# Full YAML Structure

```text
Gateway
├── apiVersion: gateway.networking.k8s.io/v1
├── kind: Gateway
├── metadata
│   ├── name: my-gateway
│   ├── namespace: default
│   ├── labels
│   │   └── app: edge-gateway
│   └── annotations
│       └── description: entry point for cluster traffic
└── spec
    ├── gatewayClassName: nginx
    ├── listeners[]
    │   ├── name: http
    │   ├── protocol: HTTP
    │   ├── port: 80
    │   ├── hostname: example.com
    │   ├── allowedRoutes
    │   │   ├── namespaces
    │   │   │   └── from: Same
    │   │   └── kinds[]
    │   │       └── kind: HTTPRoute
    │   │
    │   └── tls
    │       ├── mode: Terminate
    │       └── certificateRefs[]
    │           ├── name: tls-secret
    │
    └── addresses[]
        ├── type: IPAddress
        └── value: 10.0.0.10
