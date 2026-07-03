# StatefulSet – Kubernetes Mental Model

A StatefulSet is used to manage **stateful applications** where each Pod needs a **stable identity, stable network name, and stable storage**.

---

# Full YAML Structure

```text
StatefulSet
├── apiVersion: apps/v1
├── kind: StatefulSet
├── metadata
│   ├── name: my-statefulset
│   ├── namespace: default
│   ├── labels
│   │   └── app: mysql
│   └── annotations
│       └── description: stateful database
│
└── spec
    ├── serviceName: mysql-headless
    │
    ├── replicas: 3
    │
    ├── selector
    │   └── matchLabels
    │       └── app: mysql
    │
    ├── updateStrategy
    │   ├── type: RollingUpdate
    │   └── rollingUpdate
    │       └── partition: 0
    │
    ├── volumeClaimTemplates[]
    │   ├── metadata
    │   │   └── name: data
    │   └── spec
    │       ├── accessModes
    │       │   └── ReadWriteOnce
    │       └── resources
    │           └── requests
    │               └── storage: 1Gi
    │
    └── template
        ├── metadata
        │   └── labels
        │       └── app: mysql
        │
        └── spec
            ├── containers[]
            │   ├── name: mysql
            │   ├── image: mysql:8
            │   ├── ports
            │   │   └── containerPort: 3306
            │   │
            │   ├── env
            │   │   ├── name: MYSQL_ROOT_PASSWORD
            │   │   └── value: rootpass
            │   │
            │   └── volumeMounts
            │       ├── name: data
            │       └── mountPath: /var/lib/mysql
            │
            ├── terminationGracePeriodSeconds: 30
            └── scheduling
                ├── nodeSelector
                ├── tolerations
                └── affinity
