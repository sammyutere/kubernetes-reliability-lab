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

## Current Status

- Step 1 complete: local toolchain and repository initialized.
- Step 2 complete: FastAPI reliability app created.
- Step 3 complete: application containerised.
- Step 4 complete: local kind cluster created.
- Step 5 complete: local container image loaded into kind.
- Step 6 complete: Kubernetes Namespace Created.

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

Create Kubernetes manifests for:

- Deployment
- Service
- ConfigMap
- Probes
- Resource requests and limits

