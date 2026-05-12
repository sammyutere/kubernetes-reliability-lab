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

## Current Status

Step 1 complete: local toolchain and repository initialized.

## Step 2: Application Created

The project now includes a small FastAPI reliability application with:

- Health check endpoint
- Readiness check endpoint
- Prometheus metrics endpoint
- Failure simulation endpoint
- Latency simulation endpoint
- CPU load simulation endpoint
- Unit tests


## Step 3: Application Containerised

The FastAPI reliability app now includes:

- Production-style Dockerfile
- Non-root container user
- Pinned Python dependencies
- Prometheus metrics endpoint
- Local container run instructions
- Makefile targets for build, run, test, logs, and cleanup


## Step 4: Local kind Cluster Created

The project now includes a local multi-node Kubernetes cluster configuration using kind.

Cluster shape:

- 1 control-plane node
- 2 worker nodes

This local cluster is used to test Kubernetes workloads before deploying to AWS EKS.

