# Part 10 — Release Decision Criteria and Progressive Delivery Governance

## Objective

Document the release controls used to determine whether a canary deployment should be promoted, paused, or rolled back.

This phase demonstrates that successful deployment is not sufficient for release promotion. A release must satisfy operational and reliability requirements before additional traffic is assigned.

---

# Release Model

```txt
Stable Frontend
      │
      ▼
 90% Traffic

Canary Frontend
      │
      ▼
 10% Traffic
```

The canary receives a limited portion of production traffic so that release risk is constrained while operational signals are evaluated.

---

# Promotion Criteria

A canary release may be promoted when:

- Deployment rollout completes successfully
- Pods remain healthy
- Readiness probes succeed
- Liveness probes succeed
- Application metrics remain available
- No critical alerts are triggered
- Service-level objectives remain healthy
- Error budget remains above release threshold
- Operator validation is completed

---

# Rollback Criteria

A release should be rolled back when:

* Canary deployment becomes unhealthy
* Readiness probes fail
- Error rates increase unexpectedly
- Latency exceeds acceptable thresholds
- Critical alerts are triggered
- Error budget is exhausted
- Manual validation identifies unacceptable behaviour

---

# Canary Health Validation

The initial failure simulation modified the canary configuration:

```txt
API_URL=http://api:80
```

became:

```txt
API_URL=http://api-broken:80
```

The configuration change was successfully applied.

However, application responses continued to return HTTP 200.

This demonstrated an important operational lesson:

```txt
A deployment can contain defects without immediately producing
user-visible HTTP failures.
```

Simple status-code monitoring is not always sufficient for release promotion decisions.

---

# Strengthened Failure Simulation

To generate a clearer operational signal, the canary deployment was scaled to zero replicas.

```txt
Canary Deployment
       ↓
No Healthy Targets
       ↓
Unhealthy Target Group
       ↓
Traffic Exposure Limited To Canary Percentage
```

This created a stronger release-risk scenario while preserving protection for the majority of users.

---

# Reliability Engineering Lesson

The objective of a canary release is not to intentionally break production.

The objective is to:

- Detect unhealthy releases early
- Reduce blast radius
- Protect most users
- Validate operational signals
- Exercise rollback procedures
- Support safe deployment practices

The experiment demonstrated that only a small percentage of traffic was exposed to the unhealthy release.

---

# Error-Budget Release Gate

The project includes a release-gating workflow.

```txt
Healthy Error Budget
       ↓
Release Allowed

Unhealthy Error Budget
       ↓
Release Blocked
```

The release gate is designed to prevent promotion when reliability objectives are already at risk.

---

# Release Decision Matrix

| Condition              | Decision          |
| ---------------------- | ----------------- |
| Canary healthy         | Promote           |
| Canary unhealthy       | Rollback          |
| Error budget healthy   | Continue          |
| Error budget exhausted | Block             |
| Critical alerts firing | Rollback          |
| SLOs healthy           | Continue          |
| SLOs violated          | Pause or rollback |

---

# Operational Workflow

```txt
Deploy Canary
      ↓
Observe Health Signals
      ↓
Validate Metrics
      ↓
Validate Error Budget
      ↓
Promote OR Rollback
```

This workflow represents the core of progressive delivery.

---

# Evidence

Evidence collected:

```txt
Stable deployment validation
Canary deployment validation
Weighted traffic shifting
Release gate execution
Rollback execution
Operational observations
```

Location:

```txt
experiments/evidence/progressive-delivery/
```

---

# Part 11 — Automated Rollback Validation

## Objective

Validate that traffic can be returned safely to the stable release.

---

## Rollback Workflow

```txt
Canary Release
       ↓
Unhealthy Condition
       ↓
Rollback Trigger
       ↓
Traffic Returned To Stable
```

Rollback is performed before full promotion.

---

## Validation

The rollback procedure demonstrated:

- Traffic reversion capability
- Release governance
- Operational recovery workflow
- Progressive-delivery safety controls

The rollback was executed before exposing the majority of users to the unhealthy release.

---

## Key Observation

The experiment demonstrated that:

```txt
An unhealthy release can be isolated,
contained,
and reverted
before widespread customer impact occurs.
```

This is one of the primary goals of progressive delivery.

---

# Part 12 — Key Lessons Learned

## Progressive Delivery

Progressive delivery provides a mechanism for reducing deployment risk.

Benefits include:

- Reduced blast radius
- Safer deployments
- Faster detection of issues
- Improved rollback confidence

---

## Release Governance

A deployment should not automatically become a release.

Promotion requires:

- Technical validation
- Operational validation
- Reliability validation

---

## Error Budgets

Error budgets provide an objective release-control mechanism.

They allow teams to balance:

```txt
Innovation
vs
Reliability
```

---

## Observability

Monitoring and alerting are prerequisites for safe progressive delivery.

Without observability:

```txt
Canary deployments become guesswork.
```

---

## Reliability Engineering

Reliability is not achieved through deployment alone.

Reliability requires:

- Measurement
- Validation
- Controlled experimentation
- Recovery procedures
- Operational discipline

---

# Part 13 — Evidence Inventory

Evidence generated during this milestone:

```txt
00-terraform-plan.txt
01-terraform-output.txt
02-eks-nodes.txt
03-lbc-pods.txt
04-monitoring-pods.txt
05-*.json
06-stable-baseline.txt
07-stable-and-canary-deployments.txt
08-weighted-ingress-describe.txt
09-progressive-alb-dns.txt
10-baseline-status-codes.txt
11-release-gate-pass.txt
12-release-gate-blocked.txt
13-traffic-50-50-status-codes.txt
14-traffic-100-canary-status-codes.txt
15-failed-canary-status-codes.txt
16-rollback-output.txt
17-after-rollback-status-codes.txt
```

---

# Part 14 — AWS Cost-Control Cleanup

## Objective

Remove all cloud resources created for the experiment and verify that no unnecessary charges remain.

---

## Remove Progressive Delivery Resources

```bash
kubectl delete ingress frontend-progressive \
  -n reliability-lab \
  --ignore-not-found
```
## ALB Cleanup Troubleshooting

During cleanup, the initial Ingress deletion command was malformed because spaces were placed after the line-continuation backslashes.

Incorrect:

```bash
kubectl delete ingress frontend-progressive \ -n reliability-lab \ --ignore-not-found
```
Correct:

```bash
kubectl delete ingress frontend-progressive \
  -n reliability-lab \
  --ignore-not-found
```
or:

```bash
kubectl delete ingress frontend-progressive -n reliability-lab --ignore-not-found
```
If Ingress deletion hangs because Kubernetes finalizers are waiting for AWS Load Balancer cleanup, remove the finalizer manually:

```bash
kubectl patch ingress frontend-progressive \
  -n reliability-lab \
  -p '{"metadata":{"finalizers":[]}}' \
  --type=merge
```
Then retry:

```bash
kubectl delete ingress frontend-progressive -n reliability-lab --ignore-not-found
```
Verify ALB cleanup:

```bash
aws elbv2 describe-load-balancers \
  --region us-east-1 \
  --query "LoadBalancers[].[LoadBalancerName,DNSName,State.Code]" \
  --output table
```
Operational lesson:

Ingress cleanup should be verified at both Kubernetes and AWS levels because deleting the Kubernetes Ingress is what triggers AWS Load Balancer Controller to remove the ALB.

Wait for ALB deletion.

Verify:

```bash
aws elbv2 describe-load-balancers \
  --region us-east-1
```

---

## Remove Application

```bash
helm uninstall multi-service-app \
  -n reliability-lab
```

---

## Remove Monitoring

```bash
helm uninstall monitoring \
  -n monitoring
```

---

## Remove AWS Load Balancer Controller

```bash
helm uninstall aws-load-balancer-controller \
  -n kube-system
```

---

## Destroy Infrastructure

```bash
cd terraform/environments/dev

terraform destroy
```

Confirm:

```txt
yes
```

---

## Cleanup Verification

Verify:

```bash
aws eks list-clusters --region us-east-1

aws elbv2 describe-load-balancers --region us-east-1
```

Expected:

```txt
No active lab infrastructure
```

---

# Final Outcome

This milestone demonstrated:

- Progressive delivery on EKS
- Controlled traffic shifting
- Canary deployment strategy
- Release-risk management
- Error-budget release gating
- Automated rollback validation
- Operational decision criteria
- Cost-control cleanup workflow

The project now supports safe release practices in addition to deployment and reliability engineering.

