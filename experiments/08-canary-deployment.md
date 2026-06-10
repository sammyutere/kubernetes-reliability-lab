# Experiment: Canary Deployment

## Purpose

Validate a controlled canary deployment workflow.

## Model

```txt
frontend v1 = stable
frontend v2 = canary
```
## Current Implementation

This local kind lab introduces a separate frontend-v2 Deployment and frontend-canary Service.

## Validation

```bash
kubectl get deployment frontend frontend-v2 -n reliability-lab
kubectl get svc frontend frontend-canary -n reliability-lab
```
## Rollback

```bash
kubectl delete -f k8s/canary/frontend-v2.yaml
```
## Future Improvement

In EKS, canary can be improved using ALB weighted target groups, service mesh, Argo Rollouts, or progressive delivery tooling.
