# Known Limitations and Production Improvements

## Purpose

The Kubernetes Reliability Lab demonstrates production-style Platform Engineering, DevOps and Site Reliability Engineering controls, but it is not itself a live production service.

This document separates what the lab proves today from the controls that would be required before adopting the same design for a production platform.

---

## 1. Single Development Environment

### Current limitation

The project primarily operates one Amazon EKS development environment.

### Production improvement

Use separate development, test, staging and production environments, preferably across separate AWS accounts, with:

- independent IAM boundaries
- environment-specific secrets
- separate Argo CD projects
- controlled promotion between environments
- independent failure and recovery testing

---

## 2. Manual Build and Promotion Execution

### Current limitation

Container build, SBOM generation, vulnerability scanning, signing and release promotion are initiated locally.

### Production improvement

Move the complete release workflow into CI/CD so that every release automatically performs:

1. application tests
2. image build
3. SBOM generation
4. vulnerability scanning
5. image signing
6. signature verification
7. provenance capture
8. pull-request creation
9. deployment approval
10. deployment evidence collection

Cloud authentication should use short-lived workload identity rather than long-lived credentials.

---

## 3. Local-Key Cosign Signing

### Current limitation

The lab uses locally managed Cosign signing keys.

### Production improvement

Prefer keyless signing using OIDC identity, Fulcio certificates and Rekor transparency-log verification.

Production policy should verify the expected signer identity rather than only possession of a static public key.

---

## 4. Transparency-Log Verification Is Disabled

### Current limitation

The current lab trust workflow uses:

```text
--insecure-ignore-tlog=true
```

This produces the expected Cosign warning that transparency-log verification is being skipped.

### Production improvement

Require Rekor transparency-log inclusion and verify signing identity, certificate issuer and release provenance.

---

## 5. Signed-Image Admission Enforcement Was Deferred

### Current limitation

Kyverno signed-image admission enforcement was intentionally deferred after an earlier admission-controller compatibility failure.

The stable lab model therefore enforces software-supply-chain trust **before Git promotion**, while Kyverno continues to enforce Kubernetes admission controls such as:

- standard labels
- resource requests and limits
- prohibition of the mutable `latest` tag

### Production improvement

Reintroduce admission-time signature verification only after:

- pinning a compatible Kyverno version
- testing ECR access and image verification in isolation
- validating failure behaviour
- defining break-glass procedures
- confirming admission-controller stability

---

## 6. Version Tags Are Used Instead of Immutable Digests

### Current limitation

The final trusted release uses:

```text
0.1.0-supply-chain
```

The project verified that the trusted and original tags resolved to the same image digests, but tags remain mutable pointers.

### Production improvement

Promote immutable references such as:

```text
repository@sha256:<digest>
```

Git, the trust gate and Kubernetes should all refer to the same immutable digest.

---

## 7. Static Worker Capacity

### Current limitation

The final trusted release exposed a real Kubernetes capacity failure.

With three `t3.medium` workers, the cluster had enough steady-state capacity but insufficient Pod scheduling headroom for RollingUpdate surge Pods.

The scheduler reported:

```text
0/3 nodes are available: 3 Too many pods.
```

Terraform was used to increase the managed node group from three to four workers, after which the Pending Pods scheduled automatically and the rollout completed.

### Production improvement

Introduce automated capacity management using Karpenter or Cluster Autoscaler and monitor:

- allocatable Pod slots
- scheduled Pod count
- rollout surge requirements
- CPU and memory reservations
- pending workloads
- node saturation

Capacity planning should include deployment and failure headroom, not only steady-state resource usage.

---

## 8. Platform Controllers Are Not Fully Highly Available

### Current limitation

The lab does not implement the full HA topology expected for every platform controller.

### Production improvement

Evaluate:

- highly available Argo CD
- multiple controller replicas
- Pod anti-affinity
- PodDisruptionBudgets
- priority classes
- Redis HA
- dedicated platform capacity
- backup and recovery procedures

---

## 9. Argo CD Access Uses Local Port Forwarding

### Current limitation

Argo CD is accessed using:

```text
kubectl port-forward
```

### Production improvement

Use:

- private ingress
- TLS
- SSO
- RBAC
- network restrictions
- audit logging
- controlled administrative accounts
- break-glass procedures

---

## 10. Secrets Management Is Limited

### Current limitation

The lab does not implement a complete production secrets-management platform.

### Production improvement

Integrate:

- AWS Secrets Manager
- AWS KMS
- External Secrets Operator
- automated secret rotation
- namespace-scoped permissions
- secret scanning
- audited access

---

## 11. Single-Region Deployment

### Current limitation

The platform is deployed in one AWS Region.

### Production improvement

Define and test:

- recovery-time objectives
- recovery-point objectives
- backup policy
- cross-region image replication
- infrastructure recovery automation
- DNS failover
- multi-region data strategy
- disaster-recovery exercises

---

## 12. Monitoring Is Cluster-Local

### Current limitation

Prometheus, Grafana and Alertmanager run inside the same lab cluster they monitor.

### Production improvement

Consider:

- managed or external monitoring
- long-term metrics storage
- cross-cluster dashboards
- central alert routing
- retention controls
- cardinality controls
- on-call integration

---

## 13. Evidence Capture Is Partly Manual

### Current limitation

Several screenshots and command outputs are captured manually.

### Production improvement

Generate deployment evidence automatically from CI/CD and platform APIs, including:

- build identity
- Git commit
- image digest
- signature result
- vulnerability result
- SBOM reference
- policy decision
- Argo CD revision
- rollout result
- approval identity

---

## 14. Limited Load and Capacity Testing

### Current limitation

The lab includes reliability experiments, scaling tests and rollout failures but does not represent full production traffic modelling.

### Production improvement

Add:

- representative load tests
- stress tests
- soak tests
- dependency-failure testing under load
- autoscaling validation
- network-capacity analysis
- cost-versus-performance modelling

---

## 15. Cost Attribution Is Account-Level

### Current limitation

AWS Cost Explorer evidence may include account-level service costs rather than only this repository unless project cost-allocation tags are enabled.

### Production improvement

Enforce project and environment cost-allocation tags and track:

- EKS control-plane cost
- EC2 worker cost
- EBS
- NAT/data transfer
- CloudWatch
- ECR
- monitoring overhead

---

## Highest-Priority Production Improvements

The ten highest-value improvements would be:

1. CI-driven build, scan, signing and promotion
2. keyless signing with Rekor verification
3. immutable digest-based deployment
4. stable admission-time signature enforcement
5. separate AWS accounts and environments
6. automated Kubernetes capacity management
7. production secrets management
8. highly available platform controllers
9. disaster-recovery design and testing
10. automated release evidence and audit capture

---

## Conclusion

The Kubernetes Reliability Lab demonstrates the technical foundations of a reliable and governed Kubernetes platform.

Its most important production lesson is that reliability depends not only on application health but also on:

- infrastructure capacity
- deployment headroom
- control-plane availability
- policy enforcement
- software-supply-chain trust
- observability
- repeatable recovery

The documented limitations are intentional boundaries of the portfolio project rather than hidden gaps.
