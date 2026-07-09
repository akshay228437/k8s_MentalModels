# Kubernetes Probes – Production Mental Model

Kubernetes Probes define **how Kubernetes determines whether an application is healthy, ready to serve traffic, or still starting up**.

In production environments:

- **Startup Probe** prevents slow-starting applications from being killed.
- **Liveness Probe** automatically restarts hung or dead applications.
- **Readiness Probe** controls whether a Pod receives traffic from a Service.

---

# Production YAML Structure

```text
Deployment
└── spec
    └── template
        └── spec
            └── containers[]
                ├── name: payment-api
                ├── image: company/payment-api:v2.8.1
                ├── imagePullPolicy: IfNotPresent
                │
                ├── ports[]
                │   ├── containerPort: 8080
                │   └── name: http
                │
                ├── startupProbe
                │   ├── httpGet
                │   │   ├── path: /startup
                │   │   ├── port: http
                │   │   ├── scheme: HTTP
                │   │   └── httpHeaders[]
                │   │       └── User-Agent: kubelet
                │   │
                │   ├── initialDelaySeconds: 10
                │   ├── periodSeconds: 5
                │   ├── timeoutSeconds: 2
                │   ├── successThreshold: 1
                │   └── failureThreshold: 30
                │
                ├── livenessProbe
                │   ├── httpGet
                │   │   ├── path: /health
                │   │   ├── port: http
                │   │   ├── scheme: HTTP
                │   │   └── httpHeaders[]
                │   │       └── User-Agent: kubelet
                │   │
                │   ├── initialDelaySeconds: 30
                │   ├── periodSeconds: 15
                │   ├── timeoutSeconds: 3
                │   ├── successThreshold: 1
                │   └── failureThreshold: 3
                │
                └── readinessProbe
                    ├── httpGet
                    │   ├── path: /ready
                    │   ├── port: http
                    │   ├── scheme: HTTP
                    │   └── httpHeaders[]
                    │       └── User-Agent: kubelet
                    │
                    ├── initialDelaySeconds: 5
                    ├── periodSeconds: 10
                    ├── timeoutSeconds: 2
                    ├── successThreshold: 1
                    └── failureThreshold: 2
```

---

# Startup Probe (Production)

```text
startupProbe
├── httpGet
│   ├── path: /startup
│   ├── port: http
│   ├── scheme: HTTP
│   └── httpHeaders[]
│       └── User-Agent: kubelet
│
├── initialDelaySeconds: 10
├── periodSeconds: 5
├── timeoutSeconds: 2
├── successThreshold: 1
└── failureThreshold: 30

Purpose
├── Java Spring Boot startup
├── Large cache warm-up
├── Database migrations
└── Loading ML models
```

---

# Liveness Probe (Production)

```text
livenessProbe
├── httpGet
│   ├── path: /health
│   ├── port: http
│   └── scheme: HTTP
│
├── initialDelaySeconds: 30
├── periodSeconds: 15
├── timeoutSeconds: 3
├── successThreshold: 1
└── failureThreshold: 3

Production Example
├── Detect deadlock
├── Detect JVM freeze
├── Detect memory leak
└── Restart unhealthy container
```

---

# Readiness Probe (Production)

```text
readinessProbe
├── httpGet
│   ├── path: /ready
│   ├── port: http
│   └── scheme: HTTP
│
├── initialDelaySeconds: 5
├── periodSeconds: 10
├── timeoutSeconds: 2
├── successThreshold: 1
└── failureThreshold: 2

Production Example
├── Database connected?
├── Redis available?
├── Kafka connected?
├── Secrets loaded?
└── Ready for user traffic
```

---

# Exec Probe Example

```text
livenessProbe
└── exec
    └── command[]
        ├── sh
        ├── -c
        └── ps aux | grep payment-api
```

Production Use Cases

```text
├── Verify background worker
├── Verify cron process
├── Check generated PID file
└── Check mounted filesystem
```

---

# TCP Probe Example

```text
readinessProbe
└── tcpSocket
    └── port: 3306
```

Production Use Cases

```text
├── MySQL
├── PostgreSQL
├── Redis
├── RabbitMQ
└── MongoDB
```

---

# gRPC Probe Example

```text
livenessProbe
└── grpc
    ├── port: 9090
    └── service: grpc.health.v1.Health
```

Production Use Cases

```text
├── gRPC microservices
├── Internal APIs
├── Service Mesh workloads
└── High-performance backends
```

---

# Probe Timing

```text
Probe Configuration
├── initialDelaySeconds
│   └── Wait before first probe
│
├── periodSeconds
│   └── Check every N seconds
│
├── timeoutSeconds
│   └── Maximum response wait time
│
├── successThreshold
│   └── Consecutive successes needed
│
└── failureThreshold
    └── Consecutive failures before failure
```

Example Timeline

```text
Application Starts
        │
        ▼
10 sec initial delay
        │
        ▼
Probe every 5 sec
        │
        ▼
30 failures allowed
        │
        ▼
Restart Container
```

---

# Real Production Flow

```text
Customer Request
        │
        ▼
Kubernetes Service
        │
        ▼
Readiness Probe
        │
   Ready?
   │     │
  Yes    No
   │      │
   ▼      ▼
Send     Remove Pod
Traffic  from Endpoints

               │
               ▼
        Liveness Probe
               │
        Healthy?
          │      │
         Yes     No
          │       │
          ▼       ▼
      Continue   Restart
       Running   Container

               │
               ▼
        Startup Probe
               │
        Startup Complete?
          │         │
         Yes        No
          │         │
          ▼         ▼
      Enable      Keep Waiting
     Liveness     (Don't Restart Yet)
```

---

# Production Best Practices

```text
Spring Boot API
├── startupProbe
│   └── Prevent restart during initialization
│
├── readinessProbe
│   └── Wait for DB, Redis, Kafka
│
└── livenessProbe
    └── Restart on deadlock

────────────────────────────

Node.js API
├── startupProbe (optional)
├── readinessProbe
└── livenessProbe

────────────────────────────

Python FastAPI
├── startupProbe
├── readinessProbe
└── livenessProbe

────────────────────────────

Go Microservice
├── startupProbe (rarely needed)
├── readinessProbe
└── livenessProbe
```

---

# Mental Model

```text
Application Starts
        │
        ▼
Startup Probe
        │
   Started?
   │      │
  Yes     No
   │       │
   ▼       ▼
Enable   Retry Until
Checks   Failure Threshold

        │
        ▼
Readiness Probe
        │
   Ready?
   │      │
  Yes     No
   │       │
   ▼       ▼
Receive  No Traffic

        │
        ▼
Liveness Probe
        │
 Healthy?
   │      │
  Yes     No
   │       │
   ▼       ▼
Running  Restart Container
```
