# Service – Kubernetes Mental Model

A Service exposes a group of Pods and provides a **stable network endpoint** for accessing them.

Pods are ephemeral (can die anytime), but Service gives them a **fixed entry point**.

---

# Full YAML Structure

```text
Service
├── apiVersion: v1
├── kind: Service
├── metadata
│   ├── name: my-service
│   ├── namespace: default
│   ├── labels
│   │   └── app: nginx
│   └── annotations
│       └── description: exposes pods
└── spec
    ├── type: ClusterIP
    ├── selector
    │   └── app: nginx
    ├── ports[]
    │   ├── port: 80
    │   ├── targetPort: 8080
    │   └── protocol: TCP
    ├── sessionAffinity: None
    └── externalTrafficPolicy: Cluster
