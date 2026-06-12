# Phase 10B — EKS Multi-Service Reliability Promotion

## Objective

Promote the validated local multi-service reliability architecture into Amazon EKS and validate cloud-hosted reliability behaviour.

The goal is to demonstrate:

- Environment reconstruction after AWS cleanup
- Infrastructure validation
- ECR image promotion
- Multi-service deployment to EKS
- ALB ingress exposure
- Observability validation
- Cascading failure experimentation
- MTTR measurement
- Cost-control cleanup workflow

---

# Architecture

```txt
Internet
    ↓
AWS ALB
    ↓
Ingress
    ↓
Frontend Service
    ↓
Frontend Deployment
    ↓
API Service
    ↓
API Deployment
    ↓
Dependency Service
    ↓
Dependency Deployment
```
---

# Environment Reconstruction and Validation

This project assumes AWS resources may have been removed during cost-control exercises.

The environment must therefore be rebuilt and validated before application deployment.

## Terraform Environment

Terraform operations are executed from:

```txt
terraform/environments/dev
```
### Infrastructure Deployment

```bash
cd terraform/environments/dev

terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```
Evidence:

```txt
../../../experiments/evidence/eks-multi-service/
```
---

## EKS Validation

Configure Kubernetes access:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name reliability-lab-dev
```
Verify:

```bash
kubectl get nodes -o wide
```
Expected:

```txt
All worker nodes Ready
```
---

## Namespace Recovery

Verify:

```bash
kubectl get ns
```
If missing:

```bash
kubectl create namespace reliability-lab
kubectl create namespace monitoring
```
---

## OIDC Provider Validation

Verify:

```bash
aws iam list-open-id-connect-providers
```
If missing:

```bash
eksctl utils associate-iam-oidc-provider \
  --cluster reliability-lab-dev \
  --region us-east-1 \
  --approve
```
---

## IRSA Recovery

The AWS Load Balancer Controller requires:

```txt
OIDC
↓
IAM Role
↓
Kubernetes Service Account
↓
Annotation
```
The service account was recreated manually when it was missing.

Verify:

```bash
kubectl get sa aws-load-balancer-controller \
  -n kube-system -o yaml
```
Required annotation:

```txt
eks.amazonaws.com/role-arn
```
---

## AWS Load Balancer Controller Recovery

Install:

```bash
helm upgrade --install aws-load-balancer-controller \
  eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=reliability-lab-dev \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=<vpc-id>
```
Verify:

```bash
kubectl get pods -n kube-system \
  -l app.kubernetes.io/name=aws-load-balancer-controller
```
Expected:

```txt
Running
```
---

## Monitoring Recovery

After AWS cleanup, the monitoring namespace existed but contained no resources.

Reinstall:

```bash
helm upgrade --install monitoring \
  prometheus-community/kube-prometheus-stack \
  -n monitoring
```
Verify:

```bash
kubectl get pods -n monitoring
```
Required:

```txt
Prometheus
Grafana
Alertmanager
```
---

# ECR Image Promotion

Repositories:

```txt
frontend
api
dependency
```
Create if required:

```bash
aws ecr create-repository --repository-name frontend
aws ecr create-repository --repository-name api
aws ecr create-repository --repository-name dependency
```

Build:

```bash
docker build -t frontend:0.1.0 ./services/frontend
docker build -t api:0.1.0 ./services/api
docker build -t dependency:0.1.0 ./services/dependency
```
Push:

```bash
docker push <ecr>/frontend:0.1.0
docker push <ecr>/api:0.1.0
docker push <ecr>/dependency:0.1.0
```
---

# Multi-Service Deployment

Deploy:

```bash
helm upgrade --install multi-service-app \
  helm/multi-service-app \
  -n reliability-lab \
  -f helm/multi-service-app/values-eks.yaml
```
---

# Capacity Tuning

During deployment the frontend rollout failed.

Observed:

```txt
deployment exceeded progress deadline
frontend Pods Pending
```
Investigation showed:

```txt
Node capacity limitations
Rolling update surge
Insufficient scheduling capacity
```
Resolution:

```txt
frontend replicas: 3 → 2
api replicas: 3 → 2
dependency replicas: 3 → 2
```
This maintained redundancy while fitting available node capacity.

---

# ALB Exposure

Deploy ingress:

```bash
kubectl get ingress -n reliability-lab
```
Verify:

```txt
ALB hostname assigned
```
Validate:

```bash
curl http://<alb-dns>/healthz
```
Expected:

```txt
HTTP 200
```
---

# Observability Validation

Verify:

```bash
kubectl get servicemonitor -A
```
Validate metrics:

```txt
frontend_http_requests_total
api_http_requests_total
dependency_http_requests_total
```
Prometheus:

```txt
http://127.0.0.1:9090
```
Grafana:

```txt
http://127.0.0.1:3000
```
---

# Cascading Failure Experiment

## Baseline

Expected:

```txt
HTTP 200
```
---

## Failure Injection

```bash
kubectl set env deployment/dependency \
  -n reliability-lab \
  FAILURE_MODE=error
```
---

## Expected Behaviour

```txt
dependency failure
    ↓
api degradation
    ↓
frontend degradation
    ↓
user-facing errors
```
---

## Recovery

```bash
kubectl set env deployment/dependency \ 
  -n reliability-lab \
  FAILURE_MODE=none
```

Expected:

```txt
HTTP 200 restored
```
---

# MTTR Measurement

Capture:

```txt
Failure start
Recovery start
Recovery complete
```
Measure:

```txt
MTTR = Recovery Complete - Failure Start
```
---

# Evidence

Evidence stored in:

```txt
experiments/evidence/eks-multi-service/
```
Including:

```txt
Terraform
EKS
OIDC
IRSA
Load Balancer Controller
Monitoring
ECR
Deployment
Ingress
Metrics
Failure Injection
Recovery
MTTR
```

---

# Cost-Control Cleanup

This project intentionally includes AWS cleanup to minimise ongoing charges.

After completing the experiment:

## Remove Application

```bash
helm uninstall multi-service-app \ -n reliability-lab
```
---

## Remove Monitoring

```bash
helm uninstall monitoring \ -n monitoring
```
---

## Remove AWS Load Balancer Controller

```bash
helm uninstall aws-load-balancer-controller \ -n kube-system
```
---

## Destroy Infrastructure

```bash
cd terraform/environments/dev

terraform destroy
```
Confirm:

```txt
yes
```
---

## Verify Cleanup

Verify:

```bash
aws eks list-clusters --region us-east-1
aws elbv2 describe-load-balancers --region us-east-1
```
Expected:

```txt
No active lab resources
```
---

# Key Lessons

- Infrastructure recovery is part of reliability engineering.
- OIDC and IRSA are critical dependencies for AWS controllers.
- ALB Ingress depends on AWS Load Balancer Controller health.
- Monitoring must be validated before reliability experiments.
- Capacity constraints can affect rollout success.
- Cascading failures must be measured and documented.
- Cost-control workflows are part of responsible cloud operations.

