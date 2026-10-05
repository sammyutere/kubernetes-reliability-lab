# Incident — Trusted Release Blocked by Kubernetes Pod-Density Exhaustion

## Classification

- Environment: Amazon EKS development environment
- Milestone: 17 — Final Reliability Capstone
- Incident type: Kubernetes scheduling / platform capacity
- Status: Resolved
- Customer impact: None; lab environment
- Deployment mechanism: Git → Argo CD → Amazon EKS
- Detection: Deployment progress deadline and Kubernetes scheduler events

## Summary

A trust-gated release using the `0.1.0-supply-chain` images was successfully promoted through Git and detected by Argo CD.

All three Deployments attempted rolling updates:

- frontend
- api
- dependency

The new surge Pods remained Pending and all three Deployments exceeded their progress deadlines.

The Kubernetes scheduler reported:

```text
0/3 nodes are available: 3 Too many pods.
```

The failure was therefore not caused by image verification, ECR access, Kyverno policy, image pull failure, readiness probes or application crashes.

The cluster had sufficient steady-state capacity but insufficient Pod scheduling headroom for simultaneous RollingUpdate surge replicas.

## Detection

```bash
kubectl get pods -n reliability-lab -o wide
```

```bash
kubectl get events \
  -n reliability-lab \
  --sort-by=.lastTimestamp
```

The decisive event was:

```text
FailedScheduling
0/3 nodes are available: 3 Too many pods.
```

## Existing State

The cluster had three `t3.medium` worker nodes and was already running:

- 2 frontend Pods
- 2 API Pods
- 2 dependency Pods
- Argo CD
- Kyverno
- Prometheus
- Grafana
- Alertmanager
- Prometheus Operator
- kube-state-metrics
- node-exporter
- EKS system workloads

## Root Cause

The worker nodes had reached their allocatable Pod-density limit.

RollingUpdate attempted to create new surge Pods before terminating old replicas, but the existing three-node cluster had no remaining Pod slots.

## Remediation

Terraform node-group capacity changed from:

```hcl
min_size     = 2
max_size     = 3
desired_size = 3
```

to:

```hcl
min_size     = 2
max_size     = 4
desired_size = 4
```

The instance type remained:

```hcl
instance_types = ["t3.medium"]
```

Terraform applied one in-place infrastructure change.

A fourth EKS worker joined the cluster and became Ready. The Pending Pods then scheduled automatically.

## Recovery

After additional capacity became available:

- all six application Pods became Running and Ready
- all three Deployments reached 2/2 available replicas
- the trusted `0.1.0-supply-chain` images were running
- Argo CD returned to Synced and Healthy
- no Helm upgrade, kubectl image change, or manual rollback was required

## Evidence

- `experiments/evidence/capstone/09-trusted-release-pod-capacity-failure.txt`
- `experiments/evidence/capstone/10-node-capacity-remediation-plan.txt`
- `experiments/evidence/capstone/11-trusted-release-capacity-recovery.txt`
- `experiments/evidence/capstone/12-final-argocd-eks-visual-state.txt`

## Lessons

Steady-state capacity is not sufficient for a reliable Kubernetes platform.

Capacity planning must account for RollingUpdate surge replicas, platform controllers, monitoring workloads, policy controllers, DaemonSets, Pod-density limits and maintenance/failure headroom.
