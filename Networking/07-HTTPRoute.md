# HTTPRoute – Kubernetes Gateway API Mental Model

HTTPRoute defines **how HTTP/HTTPS traffic is routed to Services** through a Gateway.

It replaces Ingress rules with a more **modular, expressive routing model**.

---

# Full YAML Structure

```text
HTTPRoute
├── apiVersion: gateway.networking.k8s.io/v1
├── kind: HTTPRoute
├── metadata
│   ├── name: my-http-route
│   ├── namespace: default
│   ├── labels
│   │   └── app: web-routing
│   └── annotations
│       └── description: routes HTTP traffic to services
└── spec
    ├── parentRefs[]
    │   ├── name: my-gateway
    │   └── sectionName: http
    │
    ├── hostnames[]
    │   ├── example.com
    │   └── api.example.com
    │
    ├── rules[]
    │   ├── matches[]
    │   │   ├── path
    │   │   │   ├── type: PathPrefix
    │   │   │   └── value: /api
    │   │   ├── method: GET
    │   │   └── headers[]
    │   │       ├── name: version
    │   │       └── value: v1
    │   │
    │   ├── filters[]
    │   │   ├── type: RequestHeaderModifier
    │   │   └── requestHeaderModifier
    │   │       ├── add[]
    │   │       │   ├── name: X-Added-By
    │   │       │   └── value: gateway
    │   │
    │   └── backendRefs[]
    │       ├── name: web-service
    │       ├── port: 80
    │       └── weight: 100
