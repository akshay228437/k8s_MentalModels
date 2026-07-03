# Secret – Kubernetes Mental Model

Secret stores **sensitive configuration data** such as passwords, tokens, and keys in base64-encoded format.

It is similar to ConfigMap but designed for **secure data handling**.

---

# Full YAML Structure

```text
Secret
├── apiVersion: v1
├── kind: Secret
├── metadata
│   ├── name: my-secret
│   ├── namespace: default
│   ├── labels
│   │   └── app: secure-app
│   └── annotations
│       └── description: sensitive credentials storage
├── type: Opaque
└── data
    ├── username: dXNlcg==        # base64 encoded
    ├── password: cGFzc3dvcmQ=    # base64 encoded
    └── config.json: ewogICJrZXkiOiAidmFsdWUiCn0=
