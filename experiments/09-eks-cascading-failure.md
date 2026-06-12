# Experiment: EKS Multi-Service Cascading Failure

## Purpose

Validate cascading failure behaviour in the EKS-hosted multi-service architecture.

## Architecture

```txt
ALB
 ↓
frontend
 ↓
api
 ↓
dependency
```
## Hypothesis

If the dependency service returns errors, API should degrade and frontend should surface user-facing 502 responses through the ALB.

## Baseline

Expected healthy response:

```txt
HTTP 200
```
## Failure Injection

```bash
kubectl set env deployment/dependency -n reliability-lab FAILURE_MODE=error
```
## Expected Failure Behaviour

- dependency returns 500
- api records dependency failures
- frontend records upstream failures
- ALB request path returns 502
- SLO/error-rate metrics increase

## Recovery

```bash
kubectl set env deployment/dependency -n reliability-lab FAILURE_MODE=none
```
## Evidence

Evidence captured in:

```txt
experiments/evidence/eks-multi-service/
```
## MTTR Tracking

| Timestamp         | Evidence File                   |
| ----------------- | ------------------------------- |
| Failure start     | `24-failure-start-time.txt`     |
| Recovery start    | `30-recovery-start-time.txt`    |
| Recovery complete | `32-recovery-complete-time.txt` |

Conclusion

This experiment validates distributed-system failure propagation in EKS. It demonstrates that reliability engineering must measure not only infrastructure health, but also service dependency health and user-facing impact.


