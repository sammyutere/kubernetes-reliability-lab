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

## Service Architecture

The application is now reachable through a Kubernetes ClusterIP Service.

```txt
reliability-lab namespace
├── Service: reliability-app
│ └── Port 80
│ └── TargetPort http → containerPort 8000
└── Deployment: reliability-app
└── ReplicaSet
├── Pod: reliability-app
├── Pod: reliability-app
└── Pod: reliability-app
```
The Service provides stable network access to Pods managed by the Deployment.
Pods may be deleted, recreated, or rescheduled, but the Service endpoint remains stable.

## Configuration Architecture

The application now receives runtime configuration from a Kubernetes ConfigMap.

```txt
ConfigMap: reliability-app-config
├── APP_NAME
├── APP_VERSION
├── APP_ENV
└── LOG_LEVEL
↓
Deployment: reliability-app
↓
Pods receive values as environment variables
```
This separates application configuration from the container image. The same image can now be reused across local Kubernetes, EKS development, staging, and production-style environments.


## Secret Configuration Architecture

The application now supports sensitive runtime configuration through a Kubernetes Secret.

```txt
Secret: reliability-app-secret
├── API_KEY
└── FEATURE_TOKEN
↓
Deployment: reliability-app
↓
Pods receive values as environment variables
```
The application verifies whether secrets are configured without exposing secret values.

## Availability Protection Architecture

The application now includes a PodDisruptionBudget.

```txt
Deployment: reliability-app
├── Pod 1
├── Pod 2
└── Pod 3

PodDisruptionBudget: reliability-app-pdb
└── minAvailable: 2
```
This protects application availability during voluntary disruption such as node drains and maintenance operations.
