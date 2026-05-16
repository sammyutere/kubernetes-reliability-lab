# Architecture

## Purpose

This project is a production-grade Kubernetes reliability lab designed to demonstrate application containerisation, local Kubernetes operations with kind, and cloud deployment to AWS EKS.

The lab starts locally and progressively evolves toward a production-style platform engineering environment.

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
## Application Flow

```txt
FastAPI source code
    ↓
Docker image: reliability-app:local
    ↓
kind image load
    ↓
Kubernetes Pod
    ↓
Deployment
    ↓
Service
    ↓
Ingress
```
## Current Components

| Component            |      Status | Purpose                                                                  |
| -------------------- | ----------: | ------------------------------------------------------------------------ |
| FastAPI app          |    Complete | Provides health, readiness, metrics, failure, latency, and CPU endpoints |
| Dockerfile           |    Complete | Packages the app as a container image                                    |
| kind cluster         |    Complete | Runs a local Kubernetes cluster using Docker containers as nodes         |
| Kubernetes manifests | In progress | Will define Namespace, Deployment, Service, and reliability objects      |
| Helm                 |     Planned | Will package Kubernetes resources for repeatable deployment              |
| Terraform            |     Planned | Will provision AWS EKS infrastructure                                    |
| Observability        |     Planned | Will provide metrics, dashboards, and alerts                             |

## Local vs AWS Target

| Local kind                      | AWS EKS                                      |
| ------------------------------- | -------------------------------------------- |
| Runs on Docker Desktop          | Runs on AWS-managed Kubernetes control plane |
| Nodes are Docker containers     | Nodes are EC2 instances or managed compute   |
| Image loaded directly into kind | Image pulled from Amazon ECR                 |
| Used for fast local testing     | Used for production-like cloud validation    |

## Reliability Design Decision

The project will eventually validate:

- Pod self-healing
- Rolling updates and rollbacks
- Resource requests and limits
- Health and readiness probes
- Horizontal scaling
- Pod disruption handling
- Observability and alerting
- Operational runbooks

## Deployment Architecture

The application is now managed by a Kubernetes Deployment.

```txt
reliability-lab namespace
└── Deployment: reliability-app
└── ReplicaSet
├── Pod: reliability-app
│ └── Container: reliability-app:local
├── Pod: reliability-app
│ └── Container: reliability-app:local
└── Pod: reliability-app
└── Container: reliability-app:local
```
The Deployment gives the app basic self-healing behaviour. If a Pod is deleted or fails, Kubernetes creates a replacement to maintain the declared replica count.
