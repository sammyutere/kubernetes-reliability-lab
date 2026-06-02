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

## Reliability Experiments

| Experiment | Outcome |
|---|---|
| Kill Pod | Deployment self-healing validated |
| Bad Rollout | Failure detection and recovery validated |
| CPU Spike & HPA | Autoscaling behaviour evaluated |
| Node Drain | Planned maintenance behaviour validated |
| NetworkPolicy | Traffic control behaviour validated |

## Implementation Progress

### Step 1 — Engineering Environment and Repository Setup

Completed:

- Local engineering toolchain installation
- GitHub repository initialization
- Repository structure creation
- Makefile workflow initialization
- Python virtual environment setup

### Step 2 — Reliability Application Development

Completed:

- FastAPI reliability application
- Health check endpoint
- Readiness check endpoint
- Prometheus metrics endpoint
- Failure simulation endpoint
- Latency simulation endpoint
- CPU load simulation endpoint
- Unit tests

### Step 3 — Application Containerisation

Completed:

- Production-style Dockerfile
- Non-root container execution
- Docker image build workflow
- Local container runtime validation
- `.dockerignore` optimization
- Makefile Docker automation

### Step 4 — Local Kubernetes Cluster Creation

Completed:

- Multi-node local Kubernetes cluster using kind
- Kubernetes control-plane node
- Kubernetes worker nodes
- kubectl cluster access
- Local cluster validation

### Step 5 — Container Image Integration with kind

Completed:

- Local Docker image loaded into kind cluster
- Image validation inside Kubernetes node runtime
- Local Kubernetes image workflow established

### Step 6 — Kubernetes Namespace Creation

Completed:

- Dedicated `reliability-lab` namespace
- Declarative Namespace manifest
- Namespace labels for ownership and environment metadata
- kubectl context updated to use the project namespace

### Step 7 — Kubernetes Deployment Creation

Completed:

- Declarative Deployment manifest
- 3-replica application workload
- Local kind image usage with `IfNotPresent`
- Readiness probe configuration
- Liveness probe configuration
- CPU and memory requests
- CPU and memory limits
- Basic Pod self-healing validation

### Step 8 — Kubernetes Service Creation

Completed:

- Declarative ClusterIP Service manifest
- Stable internal endpoint for the reliability app
- Label selector routing to Deployment Pods
- Service-to-Pod port mapping
- Endpoint validation
- Local access through `kubectl port-forward`

### Step 9 — Kubernetes ConfigMap Creation

Completed:

- Declarative ConfigMap manifest
- Runtime configuration separated from container image
- ConfigMap injected into Pods as environment variables
- Deployment updated to consume externalised configuration
- Configuration rollout behaviour validated

### Step 10 — Kubernetes Secret Creation

Completed:

- Safe example Secret manifest
- Local ignored Secret workflow
- Secret injected into Pods as environment variables
- App updated to verify secret presence without exposing values
- Deployment updated to consume ConfigMap and Secret values

### Step 11 — PodDisruptionBudget Creation

Completed:

- Declarative PodDisruptionBudget manifest
- Availability protection with `minAvailable: 2`
- Voluntary disruption control for the reliability app
- Node drain experiment documentation

### Step 12 — HorizontalPodAutoscaler Creation

Completed:

- Metrics Server installed for local resource metrics
- Declarative HPA manifest
- CPU-based autoscaling policy
- Minimum and maximum replica bounds
- Load-test script for autoscaling validation
- HPA experiment documentation

### Step 13 — NetworkPolicy Creation

Completed:

- Declarative NetworkPolicy manifest
- Ingress traffic control model
- Allowed client Pod validation
- Denied client Pod validation
- Evidence capture for policy behaviour
- Documentation of CNI enforcement dependency

### Step 14 — Helm Chart Creation

Completed:

- Helm chart for reliability app
- Parameterised Deployment, Service, ConfigMap, HPA, PDB, and NetworkPolicy templates
- Local and EKS values files
- Helm lint and template validation
- Helm install/upgrade workflow
- Helm evidence capture
- Resolved Helm ownership conflicts from previously kubectl-managed resources

### Step 15 — Prometheus and Grafana Installation

Completed:

- kube-prometheus-stack Helm installation
- Dedicated `monitoring` namespace
- Prometheus metrics platform
- Grafana dashboard platform
- Alertmanager, kube-state-metrics, node-exporter, and Prometheus Operator
- Local port-forward access for Prometheus and Grafana
- Observability evidence capture

### Step 16 — Prometheus Alert Rules

Completed:

- PrometheusRule alert manifest
- Deployment availability alert
- Pod restart alert
- High CPU alert
- HPA near maximum replicas alert
- PDB disruption safety alert
- Alert validation and evidence capture workflow

### Step 17 — Kill Pod Reliability Experiment

Completed:

- Manual Pod deletion experiment
- Deployment self-healing validation
- ReplicaSet replacement behaviour observed
- Service continuity validated after Pod replacement
- Evidence captured for before and after states

### Step 18 — Bad Rollout Reliability Experiment

Completed:

- Intentional bad image rollout
- Rollout failure observation
- Image pull failure diagnosis
- Service continuity check during failed rollout
- Helm rollback or corrected upgrade recovery
- Evidence captured for failure and recovery states
- Validated alternative recovery using Helm upgrade after rollback failure

### Step 19 — CPU Spike and HPA Experiment

Completed:

- CPU load generation
- HPA evaluation validation
- Metrics Server validation
- Autoscaling evidence capture
- HPA and Helm ownership conflict investigation
- Local environment tuning for autoscaling validation
- CPU metrics observation workflow compatible with macOS/kubectl versions

### Step 20 — Node Drain Reliability Experiment

Completed:

- Planned node maintenance simulation
- Node cordon and drain validation
- Pod eviction and rescheduling observation
- PodDisruptionBudget behaviour validation
- Service availability check during maintenance
- Evidence captured before, during, and after node drain

### Phase 6 Review — Reliability Experiment Consolidation

Completed:

- Reliability experiment evidence index
- Phase 6 review document
- Runbook consolidation
- EKS readiness notes
- Terraform phase preparation notes
- Documentation consistency pass

### Step 21 - AWS Infrastructure Phase — EKS Foundation

Completed:

- Terraform VPC configuration
- Terraform EKS cluster configuration
- Managed node group configuration
- ECR repository configuration
- EKS Helm values file
- ECR image push workflow
- EKS Helm deployment workflow
- AWS cleanup workflow

## Current Status

- Step 1 complete: local toolchain and repository initialized.
- Step 2 complete: FastAPI reliability app created.
- Step 3 complete: application containerised.
- Step 4 complete: local kind cluster created.
- Step 5 complete: local container image loaded into kind.
- Step 6 complete: Kubernetes Namespace created.
- Step 7 complete: Kubernetes Deployment created.
- Step 8 complete: Kubernetes Service created.
- Step 9 complete: Kubernetes ConfigMap created.
- Step 10 complete: Kubernetes Secret created.
- Step 11 complete: PodDisruptionBudget created.
- Step 12 complete: HorizontalPodAutoscaler created.
- Step 13 complete: NetworkPolicy created.
- Step 14 complete: Helm Chart created.
- Step 15 complete: Prometheus and Grafana Installed.
- Step 16 complete: Prometheus Alert Rules created.
- Step 17 complete: Kill Pod Reliability Experiment.
- Step 18 complete: Bad Rollout Reliability Experiment.
- Step 19 complete: CPU Spike and HPA Experiment.
- Step 20 complete: Node Drain Reliability Experiment.
- Phase 6 Review complete: Reliability Experiment Consolidation.
- Step 21 complete: AWS Infrastructure Phase — EKS Foundation.

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

## Current Architecture

```txt
MacBook Pro
└── Docker Desktop
    ├── reliability-app:local image
    └── kind cluster: reliability-lab
        ├── control-plane node
        ├── worker node
        └── worker node
```
## Next Milestone

Add EKS ingress and production-style exposure:

- AWS Load Balancer Controller
- ALB Ingress
- Optional DNS and HTTPS
- EKS monitoring validation
