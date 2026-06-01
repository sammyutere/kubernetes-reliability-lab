# Reliability Evidence Index

This directory contains command-output evidence captured during Kubernetes reliability experiments.

## Evidence Folders

| Folder | Purpose |
|---|---|
| `kill-pod/` | Pod deletion and Deployment self-healing evidence |
| `bad-rollout/` | Failed Helm rollout and recovery evidence |
| `cpu-hpa/` | CPU load and HPA behaviour evidence |
| `node-drain/` | Node drain, PDB, and maintenance evidence |
| `networkpolicy/` | NetworkPolicy validation evidence |
| `alerts/` | Prometheus alerting validation evidence |
| `helm/` | Helm release, rendering, and ownership evidence |
| `observability/` | Prometheus and Grafana installation evidence |

## Evidence Standard

Each experiment should capture:

```txt
Before state
During failure or load
After recovery
Relevant events or descriptions
Operational conclusion
```
## Notes

Some Kubernetes Events may not be available at capture time because Events are transient and may expire quickly in local clusters.

When screenshots are not captured, command-output evidence should be used instead.
