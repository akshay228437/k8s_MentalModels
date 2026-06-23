# Kubernetes Scheduling Mental Models (Complete)

This document combines all core Kubernetes scheduling concepts that control where Pods run, how they are restricted, and how they are prioritized.

---

# 1. Node – Worker Machine

A Node is a worker machine (VM/physical) where Pods run.

Think of it as:
- Cluster = city
- Node = building
- Pod = apartment

Node structure:
```text
Node
├── metadata
│   ├── labels
│   └── annotations
├── spec
│   ├── taints[]
│   └── podCIDR
└── status
    ├── capacity
    ├── allocatable
    └── conditions

---

# 2. NodeSelector – Simple Scheduling Filter

Selects nodes using exact label match.

Pod structure:
```text
Pod
└── spec
    └── nodeSelector
        └── disktype: ssd

Mental Model:
- Exact match only
- No logic or operators
- “Run only on these nodes”

---

# 3. NodeAffinity – Advanced Node Selection

Pod structure:
```text
Pod
└── spec
    └── affinity
        └── nodeAffinity
            ├── requiredDuringSchedulingIgnoredDuringExecution
            │   └── nodeSelectorTerms[]
            │       └── matchExpressions[]
            └── preferredDuringSchedulingIgnoredDuringExecution[]

Mental Model:
- required = hard rule
- preferred = soft rule
- supports operators (In, NotIn, Exists, Gt, Lt)

---

# 4. Taints – Node Repelling Mechanism

Node structure:
```text
Node
└── spec
    └── taints[]
        ├── key: dedicated
        ├── value: gpu
        └── effect: NoSchedule | PreferNoSchedule | NoExecute

Effects:
- NoSchedule → blocks new Pods
- PreferNoSchedule → soft avoidance
- NoExecute → evicts running Pods

Mental Model:
- “Keep out unless allowed”

---

# 5. Tolerations – Pod Permission

Pod structure:
```text
Pod
└── spec
    └── tolerations[]
        ├── key: dedicated
        ├── operator: Equal
        ├── value: gpu
        └── effect: NoSchedule

Mental Model:
- Taint = restriction on node
- Toleration = permission on pod

---

# 6. PodAffinity – Run Together

Pod structure:
```text
Pod
└── spec
    └── affinity
        └── podAffinity
            └── requiredDuringSchedulingIgnoredDuringExecution
                └── labelSelector
                    └── matchLabels
                        └── app: frontend

Mental Model:
- “Place me where similar Pods exist”

---

# 7. PodAntiAffinity – Spread Apart

Pod structure:
```text
Pod
└── spec
    └── affinity
        └── podAntiAffinity
            └── requiredDuringSchedulingIgnoredDuringExecution
                └── labelSelector
                    └── matchLabels
                        └── app: backend

Mental Model:
- “Do not run with similar Pods”
- Used for HA and fault isolation

---

# 8. PriorityClass – Importance of Pods

PriorityClass structure:
```text
PriorityClass
├── apiVersion: scheduling.k8s.io/v1
├── kind: PriorityClass
├── metadata
│   └── name: high-priority
├── value: 100000
├── globalDefault: false
└── preemptionPolicy: PreemptLowerPriority

Pod usage:
```text
Pod
└── spec
    └── priorityClassName: high-priority

Mental Model:
- Higher value = higher importance
- Can evict lower priority Pods

---

# Combined Scheduling Flow

1. NodeSelector → basic filtering
2. NodeAffinity → advanced filtering
3. Taints/Tolerations → node protection rules
4. PodAffinity → place together
5. PodAntiAffinity → spread apart
6. PriorityClass → resolves resource contention

---

# Final Mental Model Summary

- Node = where workloads run
- NodeSelector = simple filter
- NodeAffinity = expressive filter
- Taints = node rejects Pods
- Tolerations = Pod accepts node
- PodAffinity = colocate Pods
- PodAntiAffinity = distribute Pods
- PriorityClass = resolves resource contention
