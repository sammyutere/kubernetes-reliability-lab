# Reliability Experiments

## Purpose

Reliability experiments validate platform behaviour under failure, load, and maintenance scenarios.

## Completed Experiments

### Kill Pod

Validated Deployment self-healing.

### Bad Rollout

Validated release failure detection and recovery procedures.

### CPU Spike and HPA

Validated autoscaling evaluation and local tuning requirements.

### Node Drain

Validated maintenance workflows and PodDisruptionBudget behaviour.

### NetworkPolicy

Validated traffic control and namespace isolation concepts.

## Evidence

Evidence is stored under:

```txt
experiments/evidence/
```
Each experiment contains:

- before state
- during state
- after state
- operational conclusion

## Operational Lessons

Experiments should be evidence-driven rather than assumption-driven.
