# Phase 10A — Multi-Service Reliability Engineering

## Objective

Transform the project from a single-service Kubernetes application into a realistic multi-service reliability engineering platform.

This phase focuses on modelling service dependencies, defining reliability objectives, simulating failures, and measuring recovery behaviour.

---

# Architecture Evolution

## Previous Architecture

```txt
Client
  ↓
reliability-app
```

## Multi-Service Architecture

```txt
Client
  ↓
Frontend
  ↓
API
  ↓
Dependency
```

The architecture intentionally introduces dependency relationships so that service failures can be observed and analysed.

---

# Services

## Frontend

Responsibilities:

- User-facing application
- Sends requests to API

Environment Variables:

```txt
API_URL
REQUEST_TIMEOUT_SECONDS
```

---

## API

Responsibilities:

- Business logic layer
- Calls dependency service

Environment Variables:

```txt
DEPENDENCY_URL
REQUEST_TIMEOUT_SECONDS
```

---

## Dependency

Responsibilities:

- Simulated backend dependency
- Supports failure injection

Environment Variables:

```txt
FAILURE_MODE
LATENCY_MS
```

---

# Failure Domain Modelling

The architecture introduces multiple failure domains.

```txt
Dependency Failure
    ↓
API Degradation
    ↓
Frontend Degradation
```

This allows controlled reliability experimentation.

---

# Local Deployment

Environment:

```txt
kind
```

Deployment Method:

```txt
Helm
```

Namespaces:

```txt
reliability-lab
```

---

# Reliability Objectives

## Service Level Indicators (SLIs)

Measured:

```txt
Availability
Request Success Rate
Response Latency
Error Rate
```

---

## Service Level Objectives (SLOs)

Example Targets:

```txt
99.9% Availability
95th Percentile Latency < 500ms
Error Rate < 1%
```

---

## Error Budget

Example:

```txt
Availability Target: 99.9%

Permitted Failure:
0.1%
```

The error budget represents acceptable unreliability before release restrictions are applied.

---

# Cascading Failure Experiment

## Objective

Observe the impact of dependency failure on upstream services.

---

## Failure Injection

Dependency configured:

```txt
FAILURE_MODE=error
```

Expected Behaviour:

```txt
Dependency Failure
    ↓
API Errors
    ↓
Frontend Errors
```

---

## Recovery

Restore:

```txt
FAILURE_MODE=none
```

Validate recovery.

---

# Mean Time To Recovery (MTTR)

Capture:

```txt
Failure Start
Detection Time
Recovery Start
Recovery Complete
```

Calculate:

```txt
MTTR = Recovery Complete − Failure Start
```

---

# Canary Deployment Workflow

A canary deployment workflow was introduced to support controlled release validation.

Objectives:

- Validate new releases safely
- Reduce deployment risk
- Support progressive delivery

---

# Error Budget Gating

An example release-gating workflow was introduced.

Purpose:

```txt
Healthy SLOs
    ↓
Allow Release

Error Budget Exhausted
    ↓
Block Release
```

---

# Chaos Engineering Expansion

Additional chaos scenarios were introduced:

- Dependency outage simulation
- Latency injection
- Recovery validation
- Service dependency testing

---

# Evidence

Evidence stored in:

```txt
experiments/evidence/multi-service/
```

Examples:

```txt
Baseline validation
Cascading failure
Recovery validation
MTTR measurements
Canary workflow validation
Error budget gating validation
```

---

# Key Lessons

- Reliability is a system property rather than a service property.
- Dependency failures frequently become user-facing failures.
- SLIs and SLOs provide measurable reliability targets.
- Error budgets support risk-based release decisions.
- MTTR is a critical operational metric.
- Multi-service architectures require failure-domain awareness.

