# AWS EKS Phase

## Purpose

This phase moves the Kubernetes Reliability Lab from local kind to AWS EKS.

## Architecture

```txt
Docker image
↓
Amazon ECR
↓
AWS EKS worker nodes
↓
Helm release
↓
reliability-app Pods
```
## Infrastructure

Terraform provisions:

- VPC
- public subnets
- internet gateway
- EKS cluster
- managed node group
- ECR repository
- IAM roles

## Deploy

```bash
cd terraform/environments/dev
terraform init
terraform apply

aws eks update-kubeconfig \
  --region eu-west-2 \
  --name reliability-lab-dev
```
## Push Image

```bash
ECR_URL=$(terraform output -raw ecr_repository_url)
AWS_REGION=$(terraform output -raw aws_region)
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

docker build -t reliability-app:0.1.0 ./app
docker tag reliability-app:0.1.0 "$ECR_URL:0.1.0"
docker push "$ECR_URL:0.1.0"
```
## Deploy App

```bash
helm upgrade --install reliability-app helm/reliability-app \
  -n reliability-lab \
  --create-namespace \
  -f helm/reliability-app/values-eks.yaml
```
## Validate

```bash
kubectl get nodes
kubectl get pods -n reliability-lab
kubectl get svc -n reliability-lab
helm status reliability-app -n reliability-lab
```
## Cleanup

```bash
helm uninstall reliability-app -n reliability-lab || true
kubectl delete namespace reliability-lab || true

cd terraform/environments/dev
terraform destroy
```

