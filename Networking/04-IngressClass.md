# IngressClass – Kubernetes Mental Model

IngressClass defines **which Ingress controller will implement an Ingress resource**.

It acts as the **binding layer between Ingress objects and Ingress controllers**.

---

# Full YAML Structure

```text
IngressClass
├── apiVersion: networking.k8s.io/v1
├── kind: IngressClass
├── metadata
│   ├── name: nginx
│   └── labels
│       └── app: ingress-controller
├── spec
│   ├── controller: k8s.io/ingress-nginx
│   └── parameters
│       ├── apiGroup: k8s.nginx.org
│       ├── kind: IngressParameters
│       └── name: nginx-params
