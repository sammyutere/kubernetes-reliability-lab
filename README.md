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

## Current Status

- Step 1 complete: local toolchain and repository initialized.
- Step 2 complete: FastAPI reliability app created.
- Step 3 complete: application containerised.
- Step 4 complete: local kind cluster created.
- Step 5 complete: local container image loaded into kind.

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

## Next Milestone

Create Kubernetes manifests for:

- Namespace
- Deployment
- Service
- ConfigMap
- Probes
- Resource requests and limits

