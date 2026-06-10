# MTTR Analysis

## Purpose

Mean Time To Recovery measures how long it takes to restore service after failure detection.

## Formula

```txt
MTTR = service restored time - failure detected time
```
## Tracking Template

| Experiment        | Failure Injected | Detected  | Recovery Started | Restored  | MTTR |
| ----------------- | ---------------- | --------- | ---------------- | --------- | ---- |
| Cascading Failure | TBD              | TBD       | TBD              | TBD       | TBD  |
| Bad Rollout       | Completed        | Completed | Completed        | Completed | TBD  |
| Node Drain        | Completed        | Completed | Completed        | Completed | TBD  |

## Why MTTR Matters

Low MTTR indicates:

- fast detection
- clear runbooks
- reliable rollback
- strong operator workflow

