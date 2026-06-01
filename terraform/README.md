# Terraform Infrastructure

## Purpose

This directory will contain infrastructure as code for the AWS EKS phase of the Kubernetes Reliability Lab.

## Planned Resources

Terraform will provision:

- VPC
- public/private subnets
- EKS cluster
- managed node group
- IAM roles
- OIDC provider
- security groups
- ECR repository

## Structure

```txt
terraform/
├── environments/
│ └── dev/
└── modules/
├── vpc/
└── eks/
```
## Planned Workflow

```bash
cd terraform/environments/dev
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```
## Cost Warning

AWS resources may incur cost.

Always destroy lab infrastructure when finished:

```bash
terraform destroy
```

