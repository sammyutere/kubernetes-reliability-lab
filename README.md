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

## Completed Capabilities 

The project currently includes:

- FastAPI reliability application
- Health check endpoint
- Readiness check endpoint
- Prometheus metrics endpoint
- Failure simulation endpoint
- Latency simulation endpoint
- CPU load simulation endpoint
- Unit tests
- Production-style Dockerfile
- Non-root container user
- Local multi-node kind cluster
- Makefile workflow helpers
- Kubernetes Deployment running 3 app replicas
- Liveness and readiness probes configured
- Basic Kubernetes self-healing demonstrated
- Internal Kubernetes Service exposing the app
- Stable Service endpoint in front of disposable Pods
- Port-forward access for local validation
- Runtime configuration managed through Kubernetes ConfigMap
- Same container image can support multiple environment configurations
- Sensitive runtime configuration pattern using Kubernetes Secret
- Git-safe secret handling with committed example and ignored local file
- PodDisruptionBudget protecting minimum app availability during voluntary disruption
- Node drain experiment documented
- CPU-based horizontal autoscaling using Kubernetes HPA
- Metrics Server integration for local kind resource metrics
- Load-test workflow for autoscaling validation
- NetworkPolicy manifest for least-privilege ingress control
- Network policy validation workflow with captured evidence
- Helm-packaged Kubernetes application release
- Environment-specific values for local kind and future EKS deployment
- Helm validation and install workflow

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

Add Helm release workflow:

- Upgrade validation
- Rollback test
- Release history
- Failure recovery workflow
