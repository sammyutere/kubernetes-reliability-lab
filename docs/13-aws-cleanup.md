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



## Delete Ingress and ALB

Before destroying Terraform infrastructure, delete the Kubernetes Ingress so the AWS Load Balancer Controller can remove the ALB.

```bash
kubectl delete ingress reliability-app -n reliability-lab || true
```
Verify ALB cleanup in AWS Console or with AWS CLI before final Terraform destroy.

## Delete AWS Load Balancer Controller

```bash
helm uninstall aws-load-balancer-controller -n kube-system || true
```


## Production Hardening Cleanup

Before running Terraform destroy, remove Kubernetes-managed AWS resources first.

### Delete Ingress / ALB

```bash
kubectl delete ingress reliability-app -n reliability-lab || true
```
Wait until the ALB is removed:

```bash
aws elbv2 describe-load-balancers --region us-east-1
```
### Delete Application

```bash
helm uninstall reliability-app -n reliability-lab || true
kubectl delete namespace reliability-lab || true
```
### Delete Monitoring Stack

```bash
helm uninstall monitoring -n monitoring || true
kubectl delete namespace monitoring || true
```
### Delete AWS Load Balancer Controller

```bash
helm uninstall aws-load-balancer-controller -n kube-system || true
```
### Destroy Terraform Infrastructure

```bash
cd terraform/environments/dev
terraform destroy
```
### Verify Remaining AWS Resources

```bash
AWS_REGION=us-east-1 ./scripts/aws-cleanup-check.sh
```
### ACM and Route 53 Notes

If a certificate and DNS record were created manually, review whether to keep or delete them.

ACM DNS validation records may be retained if you want ACM to renew certificates automatically.
