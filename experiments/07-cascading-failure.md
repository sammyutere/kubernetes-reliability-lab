# Experiment: Cascading Failure

## Purpose

Validate how dependency failure propagates through a multi-service architecture.

## Hypothesis

If the dependency service returns errors, the API service should degrade and the frontend should return upstream failure responses.

## Architecture

```txt
frontend
  ↓
api
  ↓
dependency
```
## Failure Injection

```bash
kubectl set env deployment/dependency -n reliability-lab FAILURE_MODE=error
```
## Expected Behaviour

- dependency returns 500
- api returns 502/degraded response
- frontend returns 502/degraded response
- upstream failure metrics increase
- recovery restores HTTP 200 responses

## Recovery

```bash
kubectl set env deployment/dependency -n reliability-lab FAILURE_MODE=none
```
## Evidence

Evidence captured in:

```txt
experiments/evidence/multi-service/
```
## Observed Behaviour

The dependency service was placed into simulated failure mode.

The API service received failing dependency responses and returned degraded responses.

The frontend service propagated the upstream failure as user-facing 502 responses.

After restoring the dependency service, frontend responses returned to HTTP 200.

## Conclusion

The experiment validated cascading failure behaviour in a three-service architecture.

This demonstrates why timeouts, retries, circuit breakers, graceful degradation, SLOs, and alerting are important in distributed systems.
