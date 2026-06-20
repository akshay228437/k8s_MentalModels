# Kubernetes Mental Models

Learn Kubernetes by understanding how Kubernetes thinks.

Most tutorials explain YAML fields. This repository explains the mental model behind every Kubernetes resource:

* What problem it solves
* How Kubernetes controllers interpret it
* How resources relate to each other
* Common mistakes
* Production patterns
* Interview and certification insights

The goal is to move beyond memorizing YAML and start reasoning about Kubernetes like a platform engineer.

---

# Why This Repository Exists

Many engineers learn Kubernetes by memorizing commands and YAML snippets:

```yaml
kind: Deployment
spec:
  replicas: 3
```

but struggle to answer:

* Why does a Deployment create a ReplicaSet?
* Why does a Service need a selector?
* Why are NetworkPolicies additive?
* Why does a StatefulSet need a Headless Service?
* Why do PVCs bind to PVs?

This repository focuses on mental models instead of memorization.

---

# Learning Strategy

For every Kubernetes resource, we answer:

1. What is this resource?
2. Why does it exist?
3. What does Kubernetes do internally?
4. What is the controller responsible for?
5. How does it interact with other resources?
6. What are common production patterns?
7. What mistakes do engineers make?

---

# Repository Roadmap

## Workloads

```text
Pod
ReplicaSet
Deployment
StatefulSet
DaemonSet
Job
CronJob
```

### Example Questions

* Why is a Pod the smallest deployable unit?
* Why should Pods be considered ephemeral?
* Why does a Deployment own a ReplicaSet?

---

## Networking

```text
Service
EndpointSlice
Ingress
IngressClass
NetworkPolicy
Gateway
HTTPRoute
```

### Example Questions

* How does a Service find Pods?
* Why doesn't a Service directly connect to containers?
* Why are NetworkPolicies allow-lists?
* Why do multiple NetworkPolicies combine instead of conflict?

---

## Configuration

```text
ConfigMap
Secret
ServiceAccount
```

### Example Questions

* When should ConfigMaps be used?
* Why are Secrets only base64 encoded?
* How does a ServiceAccount authenticate Pods?

---

## Storage

```text
PersistentVolume
PersistentVolumeClaim
StorageClass
VolumeSnapshot
```

### Example Questions

* Why should Pods never rely on local storage?
* How does PVC binding work?
* Why is dynamic provisioning important?

---

## Security

```text
Role
ClusterRole
RoleBinding
ClusterRoleBinding
ResourceQuota
LimitRange
```

### Example Questions

* How does RBAC evaluation work?
* Why are Roles namespace scoped?
* Why are ClusterRoles cluster scoped?

---

## Scheduling

```text
NodeSelector
NodeAffinity
PodAffinity
PodAntiAffinity
Taints
Tolerations
PriorityClass
```

### Example Questions

* How does the scheduler choose a node?
* What is the difference between affinity and taints?
* When should workloads repel each other?

---

## Autoscaling

```text
HorizontalPodAutoscaler
VerticalPodAutoscaler
```

### Example Questions

* How does HPA calculate desired replicas?
* Why can HPA and VPA conflict?

---

## Reliability

```text
PodDisruptionBudget
Readiness Probe
Liveness Probe
Startup Probe
```

### Example Questions

* Why can a healthy Pod still be removed from Service endpoints?
* What problem does a PodDisruptionBudget solve?

---

# How To Use This Repository

Choose a resource:

```text
Deployment
Service
Ingress
NetworkPolicy
PVC
RBAC
StatefulSet
```

Then study it using the following structure:

1. YAML Breakdown
2. Mental Model
3. Internal Controller Logic
4. Relationships
5. Production Patterns
6. Common Mistakes
7. Troubleshooting
8. Interview Questions

---

# Target Audience

* Kubernetes Beginners
* DevOps Engineers
* Platform Engineers
* SREs
* CKA Candidates
* CKAD Candidates
* Engineers preparing for Kubernetes interviews

---

# Philosophy

Do not memorize Kubernetes.

Understand what Kubernetes is trying to achieve.

Once you understand the controller's mental model, the YAML becomes obvious.

