# Error Budget Gating

## Purpose

Error budget gating controls release velocity based on service reliability.

## Rule

```txt
If error budget remaining < 10%, block feature releases.
```
## Simulated Gate

```bash
./scripts/error-budget-gate.sh 50
./scripts/error-budget-gate.sh 5
```
Production Equivalent

In a mature platform, this gate would run in CI/CD using Prometheus, SLO tooling, or deployment governance.

