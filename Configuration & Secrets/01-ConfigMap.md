# ConfigMap – Kubernetes Mental Model

ConfigMap stores **non-sensitive configuration data** in key-value format and injects it into Pods at runtime.

---

# Full YAML Structure

```text
ConfigMap
├── apiVersion: v1
├── kind: ConfigMap
├── metadata
│   ├── name: my-config
│   ├── namespace: default
│   ├── labels
│   │   └── app: my-app
│   └── annotations
│       └── description: app configuration data
└── data
    ├── key1: value1
    ├── key2: value2
    └── config.json: |
        {
          "env": "prod",
          "debug": false
        }
