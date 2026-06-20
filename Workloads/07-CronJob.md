# CronJob – Kubernetes Mental Model

A CronJob runs Jobs on a **time-based schedule** (like Linux cron).

---

# Full YAML Structure

```text
CronJob
├── apiVersion: batch/v1
├── kind: CronJob
├── metadata
│   ├── name: my-cronjob
│   ├── namespace: default
│   ├── labels
│   │   └── app: scheduled-task
│   └── annotations
│       └── description: runs scheduled jobs
└── spec
    ├── schedule: "*/5 * * * *"
    ├── timeZone: UTC
    ├── concurrencyPolicy: Allow
    ├── startingDeadlineSeconds: 100
    ├── successfulJobsHistoryLimit: 3
    ├── failedJobsHistoryLimit: 1
    └── jobTemplate
        └── spec
            ├── completions: 1
            ├── backoffLimit: 3
            └── template
                ├── metadata
                │   └── labels
                │       └── app: scheduled-task
                └── spec
                    ├── restartPolicy: OnFailure
                    └── containers[]
                        ├── name: cron-task
                        ├── image: busybox
                        ├── command
                        │   └── ["sh", "-c", "date; echo Hello from CronJob"]
                        ├── env
                        │   └── MODE: cron
                        └── resources
                            ├── requests
                            │   ├── cpu: 100m
                            │   └── memory: 128Mi
                            └── limits
                                ├── cpu: 200m
                                └── memory: 256Mi
