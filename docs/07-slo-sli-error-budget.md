# SLI, SLO and Error Budget

## Purpose

This document introduces service reliability measurement concepts.

## Definitions

### SLI

Service Level Indicator.

Example:

```txt
Request success rate
```
## SLO

Service Level Objective.

Example:

```txt
99.9% successful requests
```
## Error Budget

Amount of unreliability permitted.

Example:

```txt
99.9% SLO

Allowed failure:
0.1%
```
## Future Metrics

The EKS phase will introduce:

- availability SLI
- latency SLI
- error rate SLI

## Future Alerting

Prometheus rules will later be extended to support SLO monitoring.
