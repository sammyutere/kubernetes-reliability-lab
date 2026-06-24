# Phase 12 — Reliability Governance and SLO Enforcement

## Objective

Convert SLOs from documentation into enforceable release controls.

## Governance Model

```txt
Metrics
  ↓
Recording Rules
  ↓
Alert Rules
  ↓
Alertmanager Routing
  ↓
Release Gate
  ↓
Reliability Scorecard
  ↓
Release Decision
```
## SLOs

| SLO               |   Target |
| ----------------- | -------: |
| Availability      | >= 99.9% |
| Error rate        |  <= 0.1% |
| p95 latency       | <= 500ms |
| Upstream failures |        0 |

## Release Policy

A release may proceed only when:

- Prometheus is healthy
- Alertmanager is healthy
- Service metrics are present
- No critical SLO alerts are firing
- Success ratio is above threshold
- Error ratio is below threshold
- p95 latency is within threshold
- Error budget remains healthy

## Block Policy

A release must be blocked when:

- Critical SLO alerts are firing
- Error budget is below release threshold
- Success ratio falls below target
- Error ratio exceeds threshold
- p95 latency exceeds threshold
- Dependency failures are present

## Alert Routing

Critical alerts route to the SRE receiver.

Warning alerts route to the platform receiver.

## Evidence

Evidence is stored in:

```txt
experiments/evidence/reliability-governance/
```
## Outcome

This phase demonstrates that reliability targets can be converted into operational release controls.
