# AWS EKS Phase

## Purpose

This document describes the transition from local kind Kubernetes to Amazon EKS.

## Why EKS?

Local kind is useful for learning Kubernetes fundamentals.

Amazon EKS introduces:

- managed control plane
- cloud networking
- IAM integration
- production-style node management
- cloud-native observability

## Planned EKS Components

- VPC
- Private and public subnets
- EKS cluster
- Managed node group
- Amazon ECR
- AWS Load Balancer Controller
- Prometheus and Grafana
- Terraform infrastructure

## Migration Path

Local:

```txt
Docker → kind → Helm
```
Cloud:

```txt
AWS → EKS → Helm
```
## Success Criteria

- Terraform deploys EKS
- Application deploys successfully
- Monitoring works
- HPA functions correctly
- Infrastructure can be destroyed cleanly

