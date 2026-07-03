# Pod – Kubernetes Mental Model

A Pod is the **smallest deployable unit** in Kubernetes.  
It represents one or more containers that run together on the same node.

---

# Full YAML Structure

```text
Pod
├── apiVersion: v1
│
├── kind: Pod
│
├── metadata
│   ├── name: my-pod
│   ├── namespace: default
│   ├── labels
│   │   ├── app: nginx
│   │   ├── env: prod
│   │   └── tier: frontend
│   │
│   ├── annotations
│   │   └── description: "frontend pod"
│   │
│   └── ownerReferences
│       └── Controlled by Deployment/ReplicaSet
│
└── spec
    ├── containers[]
    │   ├── name: nginx
    │   ├── image: nginx:1.25
    │   ├── command: ["/bin/sh"]
    │   ├── args: ["-c", "sleep 3600"]
    │   │
    │   ├── ports[]
    │   │   ├── containerPort: 80
    │   │   └── protocol: TCP
    │   │
    │   ├── env[]
    │   │   ├── name: ENV
    │   │   └── value: prod
    │   │
    │   ├── envFrom[]
    │   │   ├── configMapRef
    │   │   └── secretRef
    │   │
    │   ├── resources
    │   │   ├── requests
    │   │   │   ├── cpu: 100m
    │   │   │   └── memory: 128Mi
    │   │   └── limits
    │   │       ├── cpu: 500m
    │   │       └── memory: 512Mi
    │   │
    │   ├── volumeMounts[]
    │   │   ├── name: app-storage
    │   │   └── mountPath: /data
    │   │
    │   ├── livenessProbe
    │   ├── readinessProbe
    │   └── startupProbe
    │
    ├── initContainers[]
    │   ├── name: init-db
    │   └── image: busybox
    │
    ├── volumes[]
    │   ├── emptyDir: {}
    │   ├── configMap: {}
    │   ├── secret: {}
    │   ├── persistentVolumeClaim: {}
    │   └── hostPath: {}
    │
    ├── restartPolicy: Always
    │   ├── Always
    │   ├── OnFailure
    │   └── Never
    │
    ├── serviceAccountName: default
    │
    ├── nodeSelector
    │   └── disktype: ssd
    │
    ├── tolerations[]
    │   ├── key: dedicated
    │   ├── operator: Equal
    │   ├── value: gpu
    │   └── effect: NoSchedule
    │
    ├── affinity
    │   ├── nodeAffinity
    │   ├── podAffinity
    │   └── podAntiAffinity
    │
    ├── imagePullSecrets[]
    │   └── regcred
    │
    └── hostNetwork: false
