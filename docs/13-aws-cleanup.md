# AWS Cleanup Workflow

## Purpose

AWS resources created for this lab may incur cost. This document defines the cleanup workflow.

## Delete Kubernetes Workloads

```bash
helm uninstall reliability-app -n reliability-lab || true
kubectl delete namespace reliability-lab || true
```
## Destroy Terraform Infrastructure

```bash
cd terraform/environments/dev
terraform destroy
```
Confirm with:

```txt
yes
```
## Verify EKS Deleted

```bash
aws eks list-clusters --region eu-west-2
```
## Verify ECR Deleted

```bash
aws ecr describe-repositories --region eu-west-2
```
## Cost Notes

Resources that may incur cost:

- EKS cluster control plane
- EC2 worker nodes
- EBS volumes
- Load balancers
- CloudWatch logs
- ECR image storage

Always run terraform destroy when finished with the lab.


