# Job – Kubernetes Mental Model

A Job creates Pods that run **to completion** and ensures they finish successfully.

---

# Full YAML Structure

```text
Job
├── apiVersion: batch/v1
├── kind: Job
├── metadata
│   ├── name: my-job
│   ├── namespace: default
│   ├── labels
│   │   └── app: batch-task
│   └── annotations
│       └── description: run-to-completion workload
└── spec
    ├── completions: 1
    ├── parallelism: 1
    ├── backoffLimit: 3
    ├── activeDeadlineSeconds: 100
    ├── selector
    │   └── matchLabels
    │       └── app: batch-task
    └── template
        ├── metadata
        │   └── labels
        │       └── app: batch-task
        └── spec
            ├── restartPolicy: Never
            ├── containers[]
            │   ├── name: batch-job
            │   ├── image: busybox
            │   ├── command
            │   │   └── ["sh", "-c", "echo Hello && sleep 10"]
            │   ├── env
            │   │   └── JOB_MODE: batch
            │   └── resources
            │       ├── requests
            │       │   ├── cpu: 100m
            │       │   └── memory: 128Mi
            │       └── limits
            │           ├── cpu: 200m
            │           └── memory: 256Mi
            └── scheduling
                ├── nodeSelector
                ├── tolerations
                └── affinity
