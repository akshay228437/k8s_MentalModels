The easiest way to understand this is to think of **three different layers of security** working together.

---

# 1. Namespace Security (PSA)

This is the **security guard at the entrance**.

When you label a namespace:

```yaml
pod-security.kubernetes.io/enforce: restricted
```

every Pod created in that namespace is checked **before it is created**.

If a Pod violates the Restricted standard, Kubernetes rejects it.

For example, this Pod is rejected:

```yaml
securityContext:
  privileged: true
```

or

```yaml
securityContext:
  runAsUser: 0
```

The Pod never starts.

So PSA doesn't secure the Pod—it **checks whether the Pod is allowed to exist**.

---

# 2. RBAC (Who can do what?)

RBAC has nothing to do with Linux security.

It answers:

> **Who is allowed to access the Kubernetes API?**

Example:

```
ServiceAccount
        │
        ▼
RoleBinding
        │
        ▼
Role
        │
        ▼
Permissions
```

Your example:

```
secure-sa
      │
      ▼
RoleBinding
      │
      ▼
pod-reader Role
      │
      ▼
get
list
watch
pods
```

Now if your Pod uses

```yaml
serviceAccountName: secure-sa
```

then inside the container

```
kubectl get pods
```

works.

But

```
kubectl delete pod x
```

fails because the Role doesn't grant `delete`.

---

# 3. SecurityContext (How the container runs)

This is Linux-level security.

It controls the process inside the container.

There are two levels.

---

## Pod-level SecurityContext

Applies to every container unless overridden.

Example

```yaml
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
```

This means

```
All containers
        │
        ▼
run as UID 1000
```

instead of

```
UID 0 (root)
```

---

### runAsUser

Linux identifies users by **UID**, not names.

```
0      -> root
1000   -> normal user
1001   -> another user
```

So

```yaml
runAsUser: 1000
```

means

```
Process UID = 1000
```

---

### runAsNonRoot

```yaml
runAsNonRoot: true
```

means

> Kubernetes verifies that the container will not run as UID 0.

If the image tries to run as root,

```
runAsUser: 0
```

the Pod is rejected.

---

### seccompProfile

Seccomp filters Linux system calls.

Linux has hundreds of system calls like:

```
open()
mount()
clone()
ptrace()
kill()
```

A compromised container could try to use dangerous system calls.

Setting

```yaml
seccompProfile:
  type: RuntimeDefault
```

uses the container runtime's default filter to block many risky system calls while allowing the common ones your application needs.

---

# Container-level SecurityContext

This applies only to that specific container.

---

### allowPrivilegeEscalation

Imagine a normal user executes

```
sudo bash
```

and suddenly becomes root.

That's privilege escalation.

Setting

```yaml
allowPrivilegeEscalation: false
```

prevents the process from gaining more privileges than it started with, even if a binary has special permissions.

---

### Linux Capabilities

Traditionally, root has all privileges.

Linux splits those privileges into smaller pieces called **capabilities**.

Examples:

```
CAP_NET_ADMIN
```

Modify network interfaces.

```
CAP_SYS_ADMIN
```

Mount filesystems, change namespaces, and many other powerful operations.

```
CAP_SYS_TIME
```

Change the system clock.

Instead of giving a container full root privileges, you can grant only the capabilities it needs.

When you write:

```yaml
capabilities:
  drop:
    - ALL
```

you're saying:

> Remove every optional Linux capability.

This greatly reduces what the process can do if it's compromised.

---

# Why are some settings under Pod and others under Container?

Some settings naturally apply to the whole Pod:

```
Pod
 ├── Container A
 └── Container B
```

For example:

```
runAsUser
```

Usually both containers should run as the same user.

So it's defined once at the Pod level.

Other settings may differ between containers.

For example:

```
Container A
needs NET_BIND_SERVICE

Container B
doesn't
```

Capabilities are therefore configured per container.

---

# Putting it all together

```
Namespace
│
├── PSA
│      │
│      ├── Reject privileged Pods
│      ├── Reject root Pods
│      └── Enforce Restricted policy
│
└── Pod
      │
      ├── ServiceAccount
      │      │
      │      └── RBAC permissions
      │
      ├── Pod SecurityContext
      │      ├── runAsNonRoot
      │      ├── runAsUser
      │      └── seccompProfile
      │
      └── Container SecurityContext
             ├── allowPrivilegeEscalation
             └── capabilities.drop: ALL
```

In short:

* **PSA** decides **whether the Pod is allowed to be created**.
* **RBAC** decides **what the workload can do against the Kubernetes API**.
* **SecurityContext** decides **how the processes inside the container run on Linux**.

These mechanisms complement each other: a Pod can have minimal Linux privileges but still have excessive Kubernetes API permissions, or vice versa. A secure deployment uses all three appropriately.
