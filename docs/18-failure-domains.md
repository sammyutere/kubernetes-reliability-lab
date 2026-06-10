# Failure Domain Model

## Purpose

This document models where failures can occur in the multi-service reliability architecture.

## Architecture

```txt
frontend
  ↓
api
  ↓
dependency
```
## Failure Domains

| Domain     | Example Failure           | Expected Impact                     |
| ---------- | ------------------------- | ----------------------------------- |
| Frontend   | frontend Pods fail        | User-facing outage                  |
| API        | API Pods fail             | frontend returns upstream failure   |
| Dependency | dependency fails          | API degrades, frontend degrades     |
| Node       | worker node unavailable   | Pods reschedule if capacity exists  |
| Release    | bad image/config deployed | rollout failure                     |
| Metrics    | Prometheus unavailable    | observability and alerting degraded |

## Cascading Failure Path

dependency failure
    ↓
api dependency failures increase
    ↓
frontend upstream failures increase
    ↓
user-facing error rate increases

## Operational Goal

Prevent a dependency failure from becoming an uncontrolled platform failure.
