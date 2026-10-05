# Kubernetes Reliability Lab

A production-style **Platform Engineering, DevOps and Site Reliability Engineering** project demonstrating how to provision, deploy, observe, govern, secure and recover a multi-service Kubernetes platform on Amazon EKS.

The repository is designed as an engineering case study with implementation, failure evidence, recovery evidence, runbooks, incident records and production trade-offs—not simply as a collection of Kubernetes tutorials.

---

## Project Summary

The project implements the operational path from infrastructure provisioning to trusted GitOps deployment:

```text
Terraform
   ↓
AWS / Amazon EKS
   ↓
Container Build / Amazon ECR
   ↓
Cosign + Grype + SBOM Trust Gate
   ↓
Git Desired State
   ↓
Argo CD
   ↓
Kyverno Admission Governance
   ↓
Kubernetes Workloads
   ↓
Prometheus / Grafana / Alertmanager
   ↓
Incident Detection / Recovery / Evidence
```

The application consists of:

- frontend
- API
- dependency

The platform demonstrates:

- Infrastructure as Code
- Helm application packaging
- GitOps reconciliation
- drift detection and self-healing
- automated pruning
- policy-as-code
- software-supply-chain verification
- observability
- SLI/SLO engineering
- controlled reliability experiments
- incident response
- platform-capacity remediation
- operational documentation

---

## Engineering Problem

Running an application on Kubernetes is not enough to demonstrate reliable platform engineering.

A production-style platform must answer:

- How is infrastructure recreated?
- How is desired state reviewed and approved?
- How are applications deployed without configuration drift?
- How are unsafe Kubernetes resources blocked?
- How are container images verified before release?
- How is runtime health observed?
- How are failures diagnosed and recovered?
- How is operational evidence retained?
- How are platform costs controlled?

This repository implements and documents those controls.

---

## Final Platform Architecture

See:

**[Final Platform Architecture](docs/architecture/final-platform-architecture.md)**

The final architecture separates responsibility across:

| Component | Responsibility |
|---|---|
| Terraform | AWS and EKS infrastructure |
| Git | Approved desired state |
| Helm | Kubernetes manifest rendering |
| Argo CD | Continuous reconciliation |
| Kyverno | Kubernetes admission governance |
| Cosign | Image signature verification |
| Grype | Vulnerability evidence |
| Syft / CycloneDX | SBOM evidence |
| Prometheus | Metrics and alert evaluation |
| Grafana | Operational visualisation |
| Alertmanager | Alert routing |
| Amazon EKS | Workload runtime |

---

## Final GitOps Workflow

See:

**[Final GitOps Workflow](docs/architecture/final-gitops-workflow.md)**

The release path is:

```text
Build
  ↓
Push to Amazon ECR
  ↓
Generate SBOM
  ↓
Generate vulnerability evidence
  ↓
Sign image
  ↓
Verify deployment trust gate
  ↓
Update Helm desired state
  ↓
Review Git diff
  ↓
Commit / merge to main
  ↓
Argo CD reconciliation
  ↓
Kyverno admission
  ↓
EKS rolling deployment
  ↓
Prometheus / Grafana observation
```

---

## Core Platform Capabilities

### Infrastructure

- Terraform-managed AWS infrastructure
- Amazon EKS
- EKS managed node groups
- Amazon ECR
- reproducible environment lifecycle
- Terraform-managed capacity changes
- final four-node recovery state during evidence capture

### Kubernetes

- frontend, API and dependency Deployments
- Services
- ServiceMonitors
- readiness and liveness controls
- resource requests and limits
- rolling deployments
- scaling and failure experiments
- Helm packaging
- environment-specific values

### GitOps

- Argo CD
- root bootstrap Application
- AppProject governance
- child Application
- app-of-apps pattern
- automated sync
- self-healing
- automated pruning
- annotation-based resource tracking
- Git-driven configuration promotion

### Policy Governance

Kyverno enforces:

- required standard labels
- resource requests and limits
- prohibition of the mutable `latest` image tag

The lab demonstrates that an Argo CD deployment cannot bypass Kubernetes admission policy.

### Software Supply Chain

The trusted release workflow demonstrates:

- SBOM generation
- Grype vulnerability evidence
- Cosign signing
- signature verification
- Amazon ECR authentication
- fail-closed promotion
- trust-gated Git promotion

The final trusted release uses:

```text
0.1.0-supply-chain
```

for frontend, API and dependency.

### Observability

- Prometheus
- Grafana
- Alertmanager
- Prometheus Operator
- ServiceMonitor discovery
- application targets
- recording rules
- alerting
- SLI/SLO work
- error-budget concepts
- reliability dashboards

---

## Reliability Engineering

The project includes controlled reliability work covering:

- Pod deletion
- rollout failure
- rollback
- CPU pressure
- scaling
- node operations
- GitOps drift
- self-healing
- automated pruning
- Kyverno admission denial
- software-supply-chain trust failure
- platform-capacity exhaustion

---

## Final Reliability Incident

During the final trusted GitOps release, all three replacement Pods remained Pending and all three Deployments exceeded their progress deadlines.

Kubernetes reported:

```text
0/3 nodes are available: 3 Too many pods.
```

The failure was traced to **Pod-density exhaustion**, not CPU, memory, image availability, Kyverno, or application health.

Terraform increased the managed node group from three to four `t3.medium` workers.

After the fourth worker became Ready:

- Pending Pods scheduled automatically
- all three Deployments completed
- all six application Pods became Ready
- trusted `0.1.0-supply-chain` images were running
- Argo CD returned to `Synced / Healthy`

See:

- **[Incident](docs/incidents/trusted-release-pod-capacity-incident.md)**
- **[Postmortem](docs/postmortems/trusted-release-pod-density-postmortem.md)**
- **[Recovery Runbook](docs/runbooks/pod-density-rollout-recovery.md)**

This incident demonstrates an important reliability principle:

> Steady-state capacity is not sufficient; a Kubernetes platform also needs deployment and failure headroom.

---

## Evidence

The repository contains raw command outputs, JSON, YAML, logs and curated screenshots proving the implemented capabilities.

- **[Evidence Index](docs/evidence-index.md)**
- **[Runbook Index](docs/runbooks/index.md)**
- `docs/screenshots/`
- `experiments/evidence/`

The evidence layer allows reviewers to verify engineering claims rather than relying only on technology names in the README.

---

## Operational Documentation

### Incident and Recovery

- [Trusted release Pod-capacity incident](docs/incidents/trusted-release-pod-capacity-incident.md)
- [Trusted release Pod-density postmortem](docs/postmortems/trusted-release-pod-density-postmortem.md)
- [Pod-density rollout recovery runbook](docs/runbooks/pod-density-rollout-recovery.md)

### GitOps

- [GitOps and Platform Automation](docs/29-gitops-and-platform-automation.md)

### Final Capstone

- [Evidence Index](docs/evidence-index.md)
- [Runbook Index](docs/runbooks/index.md)
- [Final Platform Architecture](docs/architecture/final-platform-architecture.md)
- [Final GitOps Workflow](docs/architecture/final-gitops-workflow.md)

---

## AWS Cost Engineering

See:

**[AWS Cost Summary](docs/cost-summary.md)**

Cost-control practices include:

- Terraform-managed lifecycle
- development-sized workers
- no permanent public Argo CD load balancer
- local port forwarding
- environment destruction after evidence capture
- ECR lifecycle awareness
- cost evidence captured before cleanup

---

## Known Limitations

See:

**[Known Limitations and Production Improvements](docs/limitations.md)**

Important boundaries include:

- single development environment
- local execution of parts of the release workflow
- local-key Cosign signing
- transparency-log verification limitation
- signed-image admission enforcement deferred
- version tags rather than digest-only deployment
- static worker capacity
- non-HA platform controllers
- local Argo CD access
- limited production secrets management
- single-region deployment
- partly manual evidence capture

---

## What I Would Improve in Production

Highest-priority improvements:

1. CI-based build, scan, signing and promotion
2. short-lived workload identity
3. keyless Cosign signing
4. Rekor transparency-log verification
5. immutable digest-based deployment
6. stable admission-time signature enforcement
7. separate AWS accounts and environments
8. highly available Argo CD and monitoring
9. Karpenter or Cluster Autoscaler
10. AWS Secrets Manager and External Secrets
11. formal disaster-recovery design
12. automated release evidence and audit capture

---

## Repository Structure

```text
.
├── app/                       application source
├── docs/                      architecture and operational documentation
│   ├── architecture/
│   ├── incidents/
│   ├── postmortems/
│   ├── runbooks/
│   └── screenshots/
├── experiments/
│   └── evidence/              technical proof
├── gitops/                    Argo CD projects, applications and bootstrap
├── helm/                      application Helm chart
├── monitoring/                observability configuration
├── policies/                  Kyverno policy-as-code
├── scripts/                   operational and trust automation
├── supply-chain/              SBOM and vulnerability evidence
└── terraform/                 AWS and EKS infrastructure
```

---

## Skills Demonstrated

### Platform Engineering

- Kubernetes platform design
- Helm
- Terraform
- GitOps
- Argo CD
- Kyverno
- capacity engineering
- platform ownership boundaries

### Site Reliability Engineering

- SLIs and SLOs
- error-budget concepts
- observability
- failure testing
- incident response
- postmortems
- recovery validation
- capacity failure diagnosis

### DevOps

- Git-based delivery
- container registries
- release promotion
- infrastructure automation
- deployment trust gates
- environment recovery

### Cloud Engineering

- AWS
- Amazon EKS
- Amazon ECR
- IAM concepts
- VPC/networking
- EC2 worker capacity
- AWS cost control

### Security Engineering

- Cosign signing
- SBOM generation
- vulnerability scanning
- Kubernetes admission policy
- supply-chain trust gates
- fail-closed release controls

---

## Implementation Journey

The project progressed through seventeen structured milestones covering:

1. Kubernetes fundamentals
2. application containerisation
3. Kubernetes deployment
4. configuration and secrets
5. reliability controls
6. Helm packaging
7. monitoring and alerting
8. reliability experiments
9. Terraform-managed AWS infrastructure
10. Amazon EKS deployment
11. SLI/SLO and error-budget engineering
12. progressive delivery and failure recovery
13. production hardening
14. software-supply-chain security
15. Kyverno governance
16. GitOps and platform automation
17. final reliability capstone and portfolio packaging

The implementation journey remains documented in detail throughout `docs/`.

---

## Recruiter-Facing Summary

Designed and implemented a production-style Kubernetes reliability platform across Amazon EKS.

The project demonstrates:

- Terraform-managed AWS infrastructure
- Helm-based multi-service deployment
- Argo CD GitOps reconciliation
- Kyverno admission governance
- Prometheus and Grafana observability
- SLI/SLO and reliability engineering
- Cosign, SBOM and vulnerability trust controls
- incident response and recovery
- Kubernetes capacity diagnosis
- AWS cost-control practices

The repository provides implementation evidence and failure/recovery proof rather than relying only on technology claims.

---

## Final Project Outcome

The Kubernetes Reliability Lab evolved from a manually operated Kubernetes application into an auditable, self-healing, policy-governed and trust-gated platform-delivery case study.

The final control model is:

- **Terraform owns infrastructure.**
- **Git owns approved desired state.**
- **Argo CD owns reconciliation.**
- **Kyverno owns Kubernetes admission governance.**
- **The deployment trust gate controls release promotion.**
- **Prometheus and Grafana provide runtime visibility.**
- **Runbooks, incidents and postmortems document operational recovery.**

**Project status: final planned milestone completed.**
