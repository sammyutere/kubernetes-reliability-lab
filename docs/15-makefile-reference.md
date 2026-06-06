# Makefile Reference

## Purpose

The Makefile provides operational shortcuts for common workflows used throughout the Kubernetes Reliability Lab.

These targets reduce command repetition and provide a consistent operator interface.

---

## Common Variables

| Variable | Example |
|-----------|----------|
| APP_NAME | reliability-app |
| NAMESPACE | reliability-lab |
| AWS_REGION | us-east-1 |
| CLUSTER_NAME | reliability-lab-dev |
| DRAIN_NODE | reliability-lab-worker2 |

---

## Terraform Targets

### Initialize Terraform

```bash
make tf-dev-init
```
Equivalent:

```bash
cd terraform/environments/dev
terraform init
```
### Format Terraform

```bash
make tf-dev-fmt
```
Equivalent:

```bash
cd terraform/environments/dev
terraform fmt
```
### Validate Terraform

```bash
make tf-dev-validate
```
Equivalent:

```bash
cd terraform/environments/dev
terraform validate
```
### Plan Infrastructure

```bash
make tf-dev-plan
```
Equivalent:

```bash
cd terraform/environments/dev
terraform plan
```
### Apply Infrastructure

```bash
make tf-dev-apply
```
Equivalent:

```bash
cd terraform/environments/dev
terraform apply
```
### Destroy Infrastructure

```bash
make tf-dev-destroy
```
Equivalent:

```bash
cd terraform/environments/dev
terraform destroy
```
## EKS Targets

### Configure kubeconfig

```bash
make eks-kubeconfig
```
Equivalent:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name reliability-lab-dev
```
### Show EKS Nodes

```bash
make eks-nodes
```
Equivalent:

```bash
kubectl get nodes -o wide
```
## ECR Targets

### Login to ECR

```bash
make ecr-login
```
Equivalent:

```bash
aws ecr get-login-password --region us-east-1 \
| docker login --username AWS \
  --password-stdin \
  <account-id>.dkr.ecr.us-east-1.amazonaws.com
```
## Application Targets

### Deploy Application to EKS

```bash
make eks-deploy \
  APP_NAME=reliability-app \
  NAMESPACE=reliability-lab
```
Equivalent:

```bash
helm upgrade --install reliability-app \
  helm/reliability-app \
  -n reliability-lab \
  --create-namespace \
  -f helm/reliability-app/values-eks.yaml
```
### Remove Application

```bash
make eks-clean-app \
  APP_NAME=reliability-app \
  NAMESPACE=reliability-lab
```
Equivalent:

```bash
helm uninstall reliability-app -n reliability-lab
kubectl delete namespace reliability-lab
```
## AWS Load Balancer Controller Targets

### Check Controller Status

```bash
make lbc-status
```
Equivalent:

```bash
kubectl get deployment \
  aws-load-balancer-controller \
  -n kube-system

kubectl get pods \
  -n kube-system \
  -l app.kubernetes.io/name=aws-load-balancer-controller
```
### Check Ingress

```bash
make eks-ingress \
  APP_NAME=reliability-app \
  NAMESPACE=reliability-lab
```
Equivalent:

```bash
kubectl get ingress -n reliability-lab

kubectl describe ingress reliability-app \
  -n reliability-lab
```
### Show ALB DNS Name

```bash
make eks-alb-url \
  APP_NAME=reliability-app \
  NAMESPACE=reliability-lab
```
Equivalent:

```bash
kubectl get ingress reliability-app \
  -n reliability-lab \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```
### Notes

The Makefile should be treated as the primary operational interface for the project.

Where a Make target exists, prefer using the target rather than repeatedly typing the underlying commands.

This improves consistency and reduces operational errors.



