# AWS Cost Summary

## Current-Month Cost Evidence

Total account unblended cost returned by Cost Explorer: **$10.42 USD**

| AWS service | Cost |
|---|---:|
| Amazon Elastic Container Service for Kubernetes | $4.5322 |
| Amazon Elastic Compute Cloud - Compute | $2.6832 |
| Tax | $1.7400 |
| Amazon Virtual Private Cloud | $0.6758 |
| Amazon Route 53 | $0.5006 |
| EC2 - Other | $0.2877 |
| Amazon EC2 Container Registry (ECR) | $0.0036 |

## Important Scope Limitation

The Cost Explorer result is account-level service cost and may include AWS resources unrelated to this repository unless project cost-allocation tags are enabled.

## Principal Lab Cost Drivers

- Amazon EKS control plane
- EC2 worker nodes
- VPC/NAT networking
- EBS
- Amazon ECR
- CloudWatch

## Cost-Control Measures

- Terraform-managed lifecycle
- development-sized worker nodes
- local port forwarding rather than permanent public platform load balancers
- ECR lifecycle awareness
- environment destruction after final evidence capture

## Production Improvements

- cost-allocation tags
- Graviton evaluation
- Karpenter or Cluster Autoscaler
- Spot capacity for suitable workloads
- Savings Plans
- log-retention controls
- ECR lifecycle policies
- scheduled non-production shutdown
