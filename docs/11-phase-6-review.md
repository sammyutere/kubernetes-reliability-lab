# Phase 6 Review: Reliability Experiments

## Purpose

This review consolidates the reliability experiments completed in the Kubernetes Reliability Lab before progressing to AWS EKS and Terraform.

Phase 6 focused on validating operational behaviour under failure, load, rollout failure, and planned maintenance scenarios.

## Completed Experiments

| Experiment | File | Purpose |
|---|---|---|
| Kill Pod | `experiments/01-kill-pod.md` | Validate Deployment self-healing |
| Bad Rollout | `experiments/02-bad-rollout.md` | Validate failed release detection and recovery |
| CPU Spike and HPA | `experiments/03-cpu-spike.md` | Validate autoscaling behaviour and HPA evaluation |
| Node Drain | `experiments/04-node-drain.md` | Validate planned maintenance and PDB behaviour |
| HPA Load Test | `experiments/05-hpa-load-test.md` | Earlier HPA validation workflow |
| NetworkPolicy | `experiments/06-network-policy.md` | Validate traffic control model and CNI dependency |

## Reliability Capabilities Validated

### Self-Healing

The kill-pod experiment validated that Kubernetes restores declared state when an individual Pod is deleted.

Relevant components:

```txt
Deployment
ReplicaSet
Pod
```
## Failed Rollout Recovery

The bad rollout experiment validated that invalid image deployments can be detected and recovered.

Relevant components:

```txt
Helm
Deployment
Pod status
Events
Runbook
```
Important operational finding:

Helm rollback did not fully recover the workload in this local test. Recovery succeeded using a known-good Helm upgrade.

## Autoscaling

The CPU spike experiment validated HPA evaluation and highlighted local environment limitations.

Relevant components:

```txt
Metrics Server
HPA
Deployment
CPU requests
Pods
```
Important operational finding:

The local kind environment required lower HPA thresholds and stronger load generation to make scaling observable.

## Planned Maintenance

The node drain experiment validated maintenance behaviour and PDB interaction.

Relevant components:

```txt
kubectl drain
PodDisruptionBudget
Deployment
Service
Node scheduling
```
Important operational finding:

All application Pods were initially scheduled on one worker node because topology spread constraints had not yet been configured.

## Network Control

The NetworkPolicy experiment validated the policy manifest and highlighted the dependency on a CNI that enforces NetworkPolicy.

Relevant components:

```txt
NetworkPolicy
CNI
Pod labels
Service
```
## Evidence Summary

Evidence is stored under:

```txt
experiments/evidence/
```
Expected evidence folders:

```txt
experiments/evidence/kill-pod/
experiments/evidence/bad-rollout/
experiments/evidence/cpu-hpa/
experiments/evidence/node-drain/
experiments/evidence/networkpolicy/
experiments/evidence/alerts/
experiments/evidence/helm/
experiments/evidence/observability/
```
## Operational Lessons

1. Kubernetes controllers restore desired state, but only when the desired state is correctly defined.
2. Helm is useful for release management, but manual kubectl changes can create drift and ownership conflicts.
3. HPA depends on metrics, CPU requests, and sufficient workload pressure.
4. PDBs protect voluntary disruptions but do not solve poor Pod distribution by themselves.
5. NetworkPolicy requires compatible CNI enforcement.
6. Evidence should be captured before, during, and after reliability experiments.
7. Runbooks should reflect actual recovery behaviour, not idealised assumptions.

## Readiness for EKS/Terraform Phase

The project is ready to move into the AWS EKS/Terraform phase after the following checks pass:

- Local Helm deployment is healthy.
- Reliability experiment evidence is committed.
- Runbooks include actual recovery paths.
- README reflects current capabilities.
- Terraform folder is ready for infrastructure implementation.
- EKS values file exists as a placeholder for ECR image usage.

## Next Phase

The next phase will introduce AWS infrastructure:

```txt
Terraform VPC
Terraform EKS cluster
ECR repository
EKS Helm deployment
AWS Load Balancer Controller
EKS observability
Cloud cost cleanup
```

