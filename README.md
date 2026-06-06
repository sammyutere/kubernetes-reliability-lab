# Production-Grade Kubernetes Reliability Lab

A hands-on Kubernetes reliability engineering project using local kind and AWS EKS.

## Goals

- Build hands-on competency in production-grade Kubernetes operations, reliability engineering, and platform tooling.
- Deploy a production-style application locally and on EKS.
- Use Helm, Terraform, observability, autoscaling, and reliability experiments.
- Build a portfolio-quality DevOps/SRE project.

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

## Reliability Experiments

| Experiment | Outcome |
|---|---|
| Kill Pod | Deployment self-healing validated |
| Bad Rollout | Failure detection and recovery validated |
| CPU Spike & HPA | Autoscaling behaviour evaluated |
| Node Drain | Planned maintenance behaviour validated |
| NetworkPolicy | Traffic control behaviour validated |

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

### Current Focus

In progress:

- HTTPS with ACM
- Optional Route 53 DNS integration
- Production ingress hardening
- EKS observability refinement
- Cost optimisation and cleanup validation

## Project Status

Current Phase: Production-Style EKS Platform

Completed:

- Local Kubernetes platform
- Helm packaging and deployment
- Observability and alerting
- Reliability engineering experiments
- Terraform infrastructure provisioning
- Amazon EKS deployment
- Amazon ECR integration
- AWS Load Balancer Controller
- ALB-backed Kubernetes Ingress

In Progress:

- HTTPS with ACM
- Optional Route 53 integration
- Production ingress hardening
- EKS observability refinement
- Cost optimisation validation

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

## Current Architecture

```txt
Developer Workstation
├── Docker
│   └── reliability-app container image
├── Terraform
│   └── provisions AWS infrastructure
└── kubectl / Helm
    └── deploys application to Amazon EKS

AWS
├── Amazon ECR
│   └── reliability-app:0.1.0
├── Amazon EKS
│   ├── Managed node group
│   ├── reliability-lab namespace
│   │   ├── Deployment: reliability-app
│   │   ├── Service: reliability-app
│   │   ├── HPA
│   │   ├── PDB
│   │   ├── NetworkPolicy
│   │   └── Ingress
│   └── monitoring namespace
│       ├── Prometheus
│       └── Grafana
└── AWS Application Load Balancer
    └── Routes external HTTP traffic to the reliability-app Service
```
```txt
Internet Client
    ↓
AWS Application Load Balancer
    ↓
Kubernetes Ingress
    ↓
Service: reliability-app
    ↓
Pods: reliability-app
```
## Next Milestone

Add production hardening:

- HTTPS with ACM
- optional Route 53 DNS
- EKS observability dashboard refinement
- cost and cleanup verification
