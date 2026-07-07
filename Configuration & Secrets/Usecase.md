# Kubernetes Secrets - Deep Dive

## What is a Secret?

A **Secret** is a Kubernetes object used to store sensitive information such as:

- Database passwords
- API keys
- OAuth tokens
- SSH keys
- TLS certificates
- Docker registry credentials

Unlike a ConfigMap, a Secret is intended for confidential data.

> **Note:** Kubernetes Secrets are **Base64-encoded**, not encrypted by default. Enable **Encryption at Rest** for stronger security.

---

# Secret Types

| Secret Type | Purpose |
|-------------|---------|
| Opaque | Generic key-value secrets |
| kubernetes.io/tls | TLS certificates |
| kubernetes.io/dockerconfigjson | Docker registry credentials |
| kubernetes.io/basic-auth | Username & password |
| kubernetes.io/ssh-auth | SSH private key |
| kubernetes.io/service-account-token | Service Account token |

---

# Creating a Secret

### Using kubectl

```bash
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=MyPassword123
```

---

### Using YAML

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque

data:
  username: YWRtaW4=
  password: TXlQYXNzd29yZDEyMw==
```

---

# Accessing Secrets

## As Environment Variables

```yaml
env:
- name: DB_USERNAME
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: username

- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: password
```

Application:

```java
System.getenv("DB_PASSWORD");
```

---

## As Mounted Files

```yaml
volumes:
- name: secret-volume
  secret:
    secretName: db-secret

containers:
- name: app
  image: myapp
  volumeMounts:
  - name: secret-volume
    mountPath: /etc/secrets
```

Files created:

```
/etc/secrets/username
/etc/secrets/password
```

Read them:

```bash
cat /etc/secrets/password
```

---

# Real World Use Cases

## Use Case 1: Database Credentials

A Spring Boot application connects to MySQL.

Instead of hardcoding:

```properties
spring.datasource.username=root
spring.datasource.password=root123
```

Store them in a Secret.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret

type: Opaque

stringData:
  username: root
  password: root123
```

Deployment:

```yaml
env:
- name: DB_USERNAME
  valueFrom:
    secretKeyRef:
      name: mysql-secret
      key: username

- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: mysql-secret
      key: password
```

Benefits

- Password isn't stored in the image.
- Password can be rotated without rebuilding the application.
- Different environments (dev/test/prod) can use different credentials.

---

## Use Case 2: Pulling Images from a Private Docker Registry

Suppose your image is stored in a private registry.

Create a registry Secret:

```bash
kubectl create secret docker-registry regcred \
  --docker-server=myregistry.example.com \
  --docker-username=myuser \
  --docker-password=mypassword
```

Use it in the Pod:

```yaml
spec:
  imagePullSecrets:
  - name: regcred

  containers:
  - image: myregistry.example.com/backend:v1
```

Without this Secret:

```
ImagePullBackOff
```

With the Secret:

```
Image downloaded successfully.
```

---

## Use Case 3: TLS Certificates for Ingress

Suppose your company owns:

```
api.company.com
```

Create a TLS Secret:

```bash
kubectl create secret tls api-tls \
    --cert=tls.crt \
    --key=tls.key
```

Ingress:

```yaml
tls:
- hosts:
  - api.company.com
  secretName: api-tls
```

Ingress Controller automatically serves HTTPS using the certificate.

---

## Use Case 4: API Keys

Suppose the application calls OpenAI.

Instead of:

```java
String apiKey="sk-xxxxxxxx";
```

Create a Secret:

```yaml
stringData:
  OPENAI_API_KEY: sk-xxxxxxxx
```

Deployment:

```yaml
env:
- name: OPENAI_API_KEY
  valueFrom:
    secretKeyRef:
      name: openai-secret
      key: OPENAI_API_KEY
```

Application:

```java
System.getenv("OPENAI_API_KEY");
```

---

## Use Case 5: SSH Keys

A CI/CD Job clones a private Git repository.

Secret:

```yaml
kind: Secret
type: kubernetes.io/ssh-auth
```

Mount:

```
/root/.ssh/id_rsa
```

Git command:

```bash
git clone git@github.com:company/private-repo.git
```

---

## Use Case 6: Service-to-Service Authentication

Microservices communicate securely.

```
Payment Service
        │
        ▼
Authentication Service
```

JWT signing key stored as:

```yaml
stringData:
  JWT_SECRET: super-secret-key
```

Only authenticated services can verify tokens.

---

## Use Case 7: External Cloud Credentials

A backup Job uploads files to cloud storage.

Instead of embedding credentials:

```bash
aws s3 cp backup.sql s3://prod-backups
```

Mount AWS credentials from a Secret:

```
/root/.aws/credentials
```

This allows credential rotation without rebuilding the Job image.

---

# ConfigMap vs Secret

| Feature | ConfigMap | Secret |
|----------|-----------|---------|
| Purpose | Configuration | Sensitive Data |
| Example | LOG_LEVEL | Database Password |
| Stored As | Plain Text | Base64 Encoded |
| Mounted as File | Yes | Yes |
| Environment Variable | Yes | Yes |

---

# Best Practices

- Never hardcode passwords in source code.
- Never commit Secret YAML files containing production credentials to Git.
- Enable Encryption at Rest in Kubernetes.
- Grant Secret access only to the required ServiceAccounts using RBAC.
- Rotate credentials regularly.
- Use `stringData` when authoring Secret manifests; Kubernetes will encode them into the `data` field automatically.
- Consider using external secret managers (such as cloud secret management services or Kubernetes secret operators) for production environments.

---

# Interview Questions

### Why are Secrets Base64 encoded?

Base64 is **encoding**, not encryption. It allows binary and text data to be represented safely in YAML/JSON. Sensitive data should be protected with RBAC and encryption at rest.

---

### Can Pods update Secrets?

Pods can read mounted Secrets. Updating Secret objects requires Kubernetes API permissions (RBAC). When mounted as volumes, updated Secret values are typically reflected in the mounted files after a short delay.

---

### Difference between ConfigMap and Secret?

ConfigMap stores non-sensitive configuration.

Secret stores confidential information.

---

### Can one Secret be used by multiple Pods?

Yes.

A single Secret can be referenced by multiple Pods across the same namespace.

---

### What happens if a Secret changes?

- Mounted Secret volumes are updated automatically (with a small delay).
- Environment variables populated from Secrets are **not** updated in running containers; Pods generally need to be restarted to see new values.

---

# Summary

Secrets provide a secure mechanism to separate sensitive information from application code and container images. They are commonly used for database credentials, TLS certificates, API keys, registry authentication, SSH keys, and cloud credentials. In production, combine Secrets with RBAC, encryption at rest, and credential rotation for a stronger security posture.
