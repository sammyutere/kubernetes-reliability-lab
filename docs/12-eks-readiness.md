# EKS Readiness Notes

## Purpose

This document records what must change when moving from local kind to AWS EKS.

## Local kind Model

```txt
Docker Desktop
↓
kind nodes as Docker containers
↓
locally loaded image: reliability-app:local
```
## EKS Model

```txt
AWS EKS control plane
    ↓
managed node group or Fargate
    ↓
image pulled from Amazon ECR
```
## Required Changes for EKS

```txt
| Area          | Local kind                               | EKS                                           |
| ------------- | ---------------------------------------- | --------------------------------------------- |
| Image source  | `reliability-app:local` loaded into kind | ECR image URI                                 |
| Ingress       | Port-forward / local access              | AWS Load Balancer Controller / ALB            |
| IAM           | Local kubeconfig                         | AWS IAM and EKS auth                          |
| Storage       | Local ephemeral                          | AWS-backed storage if needed                  |
| Observability | Local Prometheus/Grafana                 | Prometheus/Grafana and/or CloudWatch          |
| Secrets       | Local ignored YAML                       | AWS Secrets Manager or External Secrets later |
| Costs         | Free local runtime                       | AWS cost management required                  |
```
## EKS Deployment Values

Placeholder file:

```txt
helm/reliability-app/values-eks.yaml
```
This file must be updated with:

```txt
ECR repository URL
EKS-specific environment name
production-like scaling values
ingress configuration
```
## Terraform Phase Requirements

Terraform should provision:

```txt
VPC
private/public subnets
EKS cluster
managed node group
IAM roles
OIDC provider
security groups
ECR repository
```
## Cost Controls

Before creating AWS resources:

- Choose a low-cost region such as eu-west-2 if appropriate.
- Use small instance types.
- Avoid unnecessary NAT Gateway usage where possible.
- Add clear terraform destroy instructions.
- Capture AWS cost assumptions in documentation.

## Migration Checklist

Before EKS deployment:

```bash
helm lint helm/reliability-app
helm template reliability-app helm/reliability-app -f helm/reliability-app/values-eks.yaml
terraform fmt
terraform validate
```
## Key Learning Transition

The Kubernetes API model remains similar between kind and EKS.

The infrastructure underneath changes:

```txt
kind node = Docker container
EKS node = AWS compute
```
This is why local Kubernetes fluency transfers to cloud Kubernetes operations.

