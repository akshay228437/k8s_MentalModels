# Endpoints – Kubernetes Mental Model

Endpoints store the **actual Pod IP addresses + ports** that a Service routes traffic to.

---

# Full YAML Structure (Endpoints)

```text
Endpoints
├── apiVersion: v1
├── kind: Endpoints
├── metadata
│   ├── name: my-service
│   ├── namespace: default
│   └── labels
│       └── app: nginx
└── subsets[]
    ├── addresses[]
    │   ├── ip: 10.244.1.10
    │   └── targetRef
    │       ├── kind: Pod
    │       └── name: nginx-pod-1
    │
    ├── ports[]
    │   ├── port: 8080
    │   └── protocol: TCP



EndpointSlice
├── apiVersion: discovery.k8s.io/v1
├── kind: EndpointSlice
├── metadata
│   ├── name: my-service-abc123
│   ├── namespace: default
│   └── labels
│       ├── kubernetes.io/service-name: my-service
│       └── endpointslice.kubernetes.io/managed-by: controller
└── endpoints[]
    ├── addresses[]
    │   └── 10.244.1.10
    │
    ├── conditions
    │   ├── ready: true
    │   ├── serving: true
    │   └── terminating: false
    │
    ├── targetRef
    │   ├── kind: Pod
    │   └── name: nginx-pod-1
    │
    └── ports[]
        ├── port: 8080
        └── protocol: TCP
