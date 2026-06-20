# Ingress – Kubernetes Mental Model

Ingress manages **external HTTP/HTTPS access** to Services inside a Kubernetes cluster.

It acts as a **smart router at the edge of the cluster**.

---

# Full YAML Structure

```text
Ingress
├── apiVersion: networking.k8s.io/v1
├── kind: Ingress
├── metadata
│   ├── name: my-ingress
│   ├── namespace: default
│   ├── labels
│   │   └── app: web
│   └── annotations
│       ├── nginx.ingress.kubernetes.io/rewrite-target: /
│       └── nginx.ingress.kubernetes.io/ssl-redirect: "true"
└── spec
    ├── ingressClassName: nginx
    ├── defaultBackend
    │   └── service
    │       ├── name: default-service
    │       └── port
    │           └── number: 80
    └── rules[]
        ├── host: example.com
        └── http
            └── paths[]
                ├── path: /
                ├── pathType: Prefix
                └── backend
                    └── service
                        ├── name: web-service
                        └── port
                            └── number: 80
