# Production-Grade Kubernetes Reliability Lab

A hands-on Kubernetes reliability engineering project using local kind and AWS EKS.

## Goals

- Build hands-on competency in production-grade Kubernetes operations, reliability engineering, and platform tooling.
- Deploy a production-style application locally and on EKS.
- Use Helm, Terraform, observability, autoscaling, and reliability experiments.
- Build a portfolio-quality DevOps/SRE project.

## Engineering Areas Demonstrated

- Kubernetes Administration
- Helm Release Management
- Terraform Infrastructure as Code
- Amazon EKS Operations
- Amazon ECR Image Management
- IAM OIDC Provider Integration
- IAM Roles for Service Accounts (IRSA)
- AWS Load Balancer Controller
- ALB Ingress Management
- Prometheus Monitoring
- Grafana Dashboards
- Alertmanager Integration
- Horizontal Pod Autoscaling (HPA)
- Pod Disruption Budgets (PDB)
- Reliability Engineering
- Failure Domain Modelling
- SLI/SLO Design
- Error Budget Management
- MTTR Measurement
- Cloud Cost Management

## Tech Stack

- Python FastAPI
- Docker
- Kubernetes
- kind
- kubectl
- Helm
- Terraform
- AWS EKS
- Prometheus
- Grafana
- GitHub Actions

## Project Structure

```txt
app/              Application source code
k8s/              Raw Kubernetes manifests
helm/             Helm chart
terraform/        AWS infrastructure as code
observability/    Monitoring, dashboards, alerts
experiments/      Reliability experiments
docs/             Architecture, runbooks, SLOs
.github/          CI workflows
```
## Documentation

| Document | Purpose |
|---|---|
| [Architecture](docs/00-architecture.md) | Current system architecture and component relationships |
| [Kubernetes Fundamentals](docs/01-kubernetes-fundamentals.md) | Kubernetes concepts learned through the project |
| [Observability](docs/04-observability.md) | Prometheus, Grafana, and metrics documentation |
| [Runbooks](docs/06-runbooks.md) | Operational recovery procedures |
| [Helm](docs/09-helm.md) | Helm packaging and release workflow |
| [Alerting](docs/10-alerting.md) | Prometheus alerting rules and validation notes |
| [Phase 6 Review](docs/11-phase-6-review.md) | Reliability experiment review |
| [EKS Readiness](docs/12-eks-readiness.md) | Preparation notes for AWS EKS phase |
| [AWS Cleanup](docs/13-aws-cleanup.md) | AWS resource cleanup and cost control workflow |
| [EKS Ingress](docs/14-eks-ingress.md) | AWS Load Balancer Controller and ALB Ingress exposure |
| [Makefile Reference](docs/15-makefile-reference.md) | Operational shortcuts and required variables |
| [Architecture](docs/00-architecture.md) | Current architecture and component relationships |
| [Project Roadmap](docs/16-project-roadmap.md) | Historical implementation journey |
| [Production Hardening](docs/17-production-hardening.md) | HTTPS, DNS, observability refinement, and cleanup verification |
| [Multi-Service Reliability Engineering](docs/22-multi-service-reliability-engineering.md) | Multi-service architecture, failure domains, SLOs, error budgets, MTTR, canary workflows, and chaos experiments |
| [EKS Multi-Service Reliability](docs/23-eks-multi-service-reliability.md) | Environment reconstruction, EKS promotion, ALB ingress, observability validation, cascading failures, MTTR, and cleanup workflow |

## Reliability Experiments

| Experiment | Outcome |
|---|---|
| Kill Pod | Deployment self-healing validated |
| Bad Rollout | Failure detection and recovery validated |
| CPU Spike & HPA | Autoscaling behaviour evaluated |
| Node Drain | Planned maintenance behaviour validated |
| NetworkPolicy | Traffic control behaviour validated |

## Reliability Engineering Journey

```txt
Local kind
    ↓
Helm
    ↓
Monitoring
    ↓
Reliability Experiments
    ↓
Terraform
    ↓
Amazon EKS
    ↓
IRSA
    ↓
AWS Load Balancer Controller
    ↓
ALB Ingress
    ↓
Multi-Service Architecture
    ↓
Cascading Failure Analysis
    ↓
MTTR Measurement
```
This repository demonstrates the progression from local Kubernetes administration to cloud-hosted reliability engineering practices.

## Implementation Progress

### Phase 1 — Application Foundation

Completed:

- Repository bootstrap and project structure
- Python reliability application development
- Health endpoints (`/healthz`, `/readyz`)
- Configuration management support
- Containerisation with Docker

### Phase 2 — Kubernetes Fundamentals (Local kind)

Completed:

- Local multi-node kind cluster
- Namespace isolation
- Deployment creation and management
- Service creation and traffic routing
- Container image loading into kind

### Phase 3 — Reliability Foundations

Completed:

- ConfigMap configuration management
- Secret management
- PodDisruptionBudget (PDB)
- HorizontalPodAutoscaler (HPA)
- NetworkPolicy implementation
- Metrics Server validation

### Phase 4 — Helm Packaging

Completed:

- Helm chart creation
- Helm values management
- Local Helm deployment workflow
- Helm upgrade workflow
- Helm rollback investigation
- Helm ownership conflict troubleshooting

### Phase 5 — Observability and Alerting

Completed:

- Prometheus installation
- Grafana installation
- PrometheusRule alerting
- Alert validation workflow
- Monitoring evidence capture
- Observability documentation

### Phase 6 — Reliability Engineering Experiments

Completed:

- Pod self-healing validation
- Bad rollout experiment
- Rollback and recovery testing
- CPU spike and HPA experiment
- Node drain experiment
- Reliability runbooks
- Evidence-driven reliability testing
- Phase 6 operational review

### Phase 7 — AWS Infrastructure

Completed:

- Terraform infrastructure provisioning
- Amazon VPC deployment
- Amazon EKS cluster deployment
- Managed node group deployment
- Amazon ECR repository creation
- EKS kubeconfig integration
- Infrastructure lifecycle management

### Phase 8 — Cloud-Native Deployment

Completed:

- Container image publishing to ECR
- Helm deployment to EKS
- EKS workload validation
- Environment-specific Helm values
- AWS cleanup workflow
- EKS readiness documentation

### Phase 9 — Production-Style Exposure

Completed:

- AWS Load Balancer Controller installation
- IAM Roles for Service Accounts (IRSA)
- Manual IAM role creation and troubleshooting
- Service account annotation troubleshooting
- ALB-backed Kubernetes Ingress
- Public application exposure through AWS ALB
- EKS ingress monitoring validation
- Ingress evidence capture

### Phase 10A — Multi-Service Reliability Engineering

Completed:

- Local multi-service architecture on kind
- Frontend, API, and dependency services
- Service dependency chain validation
- Failure domain modelling
- SLI/SLO/error budget documentation
- Cascading failure experiment
- MTTR tracking framework
- Canary deployment workflow
- Error budget gating script
- Expanded chaos experiment scripts
- Multi-service reliability evidence capture

## Current Milestone

### Phase 10B — EKS Multi-Service Reliability Promotion

Objectives:

- Environment reconstruction after AWS cleanup
- Terraform-based infrastructure recovery
- OIDC and IRSA validation
- AWS Load Balancer Controller recovery
- Monitoring stack recovery
- ECR image promotion
- Multi-service deployment to EKS
- Capacity tuning and rollout troubleshooting
- ALB ingress validation
- Observability validation
- Cascading failure experimentation
- MTTR measurement
- AWS cost-control cleanup workflow

### Phase 11 — Progressive Delivery and Release Risk Control

Completed:

- Stable and canary deployment strategy
- ALB weighted traffic shifting
- 90/10, 50/50 and promotion workflows
- Release health validation
- Error-budget release gating
- Failed-canary simulation
- Automated rollback validation
- Release decision criteria
- Progressive delivery evidence capture
- AWS cost-control cleanup workflow

### Phase 12 — Reliability Governance and SLO Enforcement

Completed:

- SLO recording rules
- Expanded Prometheus alert rules
- Alertmanager routing validation
- SLO-based release gate
- Reliability scorecard
- Operational release policy
- Reliability governance evidence capture
- Cost-control cleanup workflow

## Completed Capabilities 

The project currently includes:

### Kubernetes Platform Capabilities

- Containerised Python application
- Kubernetes Deployments
- Services
- ConfigMaps
- Secrets
- PodDisruptionBudgets
- HorizontalPodAutoscalers
- NetworkPolicies
- Helm packaging and deployment
- Prometheus and Grafana monitoring
- Reliability experiments and runbooks

### Cloud Platform Capabilities

- Terraform-based infrastructure provisioning
- Amazon EKS cluster administration
- Amazon ECR image management
- Helm-based application deployment
- Kubernetes workload migration from local to cloud environments
- AWS cost-aware lab operations
- Infrastructure lifecycle management (create, validate, destroy)
- Installed AWS Load Balancer Controller on EKS
- Exposed the reliability app through an ALB-backed Kubernetes Ingress
- Validated public HTTP access through AWS Application Load Balancer
- Captured EKS ingress and ALB evidence
- Documented optional DNS and HTTPS path
- Troubleshot EKS deployment failures caused by missing ECR images
- Created and validated IAM roles for AWS Load Balancer Controller
- Configured IAM Roles for Service Accounts (IRSA)
- Resolved service account annotation and controller authentication issues
- Diagnosed and resolved ALB provisioning failures using Kubernetes events
- Validated end-to-end AWS Load Balancer Controller integration with EKS
- Centralised operational command reference
- Standardised Makefile-based workflow execution
- Operator-focused documentation for common infrastructure tasks

### Production Hardening

- HTTPS-ready ALB ingress architecture
- ACM certificate integration workflow
- Route 53 DNS integration workflow
- EKS observability validation
- Grafana dashboard validation
- Prometheus metrics validation
- AWS cleanup verification
- Cost-aware platform management

### Platform Recovery and Troubleshooting

- Rebuilt EKS platform after full AWS cleanup
- Restored Terraform-managed infrastructure
- Revalidated ECR image supply chain
- Recreated AWS Load Balancer Controller
- Configured IRSA manually
- Resolved service account annotation issues
- Associated EKS IAM OIDC provider
- Resolved controller VPC discovery failure
- Diagnosed ALB provisioning failures
- Resolved service account annotation issues
- Recovered monitoring stack after infrastructure rebuild

### Multi-Service Reliability Engineering

- Modelled service dependency failure domains
- Simulated cascading dependency failure
- Validated frontend → api → dependency request path
- Documented SLIs, SLOs, and error budget policy
- Added MTTR tracking framework
- Added local canary deployment workflow
- Added error budget gating simulation
- Added chaos helper scripts for dependency outage and recovery

### EKS Multi-Service Reliability Promotion

- Rebuilt EKS environments after full AWS cleanup
- Restored Terraform-managed infrastructure
- Revalidated ECR image supply chain
- Associated IAM OIDC provider
- Configured IAM Roles for Service Accounts (IRSA)
- Recreated AWS Load Balancer Controller
- Diagnosed controller VPC discovery failures
- Recovered Prometheus, Grafana, and Alertmanager
- Promoted multi-service workloads to EKS
- Tuned workload capacity to resolve rollout failures
- Validated ALB ingress exposure
- Executed cloud-hosted cascading failure experiments
- Measured MTTR in EKS
- Implemented cost-control cleanup workflows

### Progressive Delivery and Release Risk Control

- Implemented canary deployment on EKS
- Introduced controlled ALB traffic shifting
- Validated release health before promotion
- Simulated failed canary release
- Automated rollback to stable traffic
- Integrated error-budget release gate
- Documented promotion and rollback criteria
- Captured progressive delivery evidence

### Reliability Governance and SLO Enforcement

- Converted SLOs into enforceable release controls
- Added Prometheus recording rules for SLO metrics
- Expanded alerting coverage for availability, latency, errors, and dependency failures
- Validated Alertmanager routing by severity
- Created SLO release gate script
- Created reliability scorecard workflow
- Defined operational release policy
- Integrated reliability governance into release decision-making

## Current Architecture

```txt

                         Internet
                             │
                             ▼
                    AWS Application Load Balancer
                             │
                             ▼
                     Kubernetes Ingress
                             │
                             ▼
                     Frontend Service
                             │
                             ▼
                         API Service
                             │
                             ▼
                    Dependency Service

──────────────────────────────────────

Amazon EKS

reliability-lab namespace

├── frontend Deployment
├── api Deployment
├── dependency Deployment
├── Services
├── HPA
├── PDB
├── Network Policies
└── Ingress

monitoring namespace

├── Prometheus
├── Grafana
└── Alertmanager

──────────────────────────────────────

AWS

├── ECR
├── IAM OIDC Provider
├── IRSA
├── AWS Load Balancer Controller
└── ALB
```
## Next Milestone

Advanced Chaos Engineering and Resilience Validation

- Inject dependency latency
- Simulate partial service outage
- Run resource exhaustion test
- Validate alert routing under failure
- Measure MTTR across failure scenarios
- Update reliability scorecard after chaos tests

## Future Roadmap

### Phase 13 — Advanced Chaos Engineering

- Dependency outages
- Latency injection
- Resource exhaustion
- Recovery measurement

### Phase 14 — Supply Chain Security

- SBOM generation
- Container scanning
- Sigstore
- Cosign signing
- Provenance verification

### Phase 15 — Platform Engineering

- OPA Gatekeeper
- Kyverno
- GitOps
- Platform governance
