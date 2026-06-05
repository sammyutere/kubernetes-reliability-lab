# EKS Ingress and Production-Style Exposure

## Purpose

This phase extends the Kubernetes Reliability Lab from an internal EKS deployment to a production-style exposure model using the AWS Load Balancer Controller and an AWS Application Load Balancer (ALB).

The objective is to expose the application through a Kubernetes Ingress resource while maintaining Infrastructure as Code, repeatable deployment workflows, and operational documentation.

---

## Architecture

```txt
Internet Client
       ↓
AWS Application Load Balancer
       ↓
Kubernetes Ingress
       ↓
Service: reliability-app
       ↓
Deployment
       ↓
Pods
```

---

## Infrastructure Preparation

Before ingress deployment, AWS infrastructure was provisioned using Terraform.

### Terraform Apply

Infrastructure components were created using:

```bash
cd terraform/environments/dev

terraform init
terraform validate
terraform plan
terraform apply
```

Provisioned resources included:

- VPC
- Public subnets
- Internet Gateway
- EKS cluster
- Managed node group
- ECR repository
- IAM roles

### Validation

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name reliability-lab-dev

kubectl get nodes
```

Successful validation confirmed that the EKS cluster was operational and worker nodes were Ready.

---

## Container Image Validation

Before deploying the application to EKS, the ECR repository was verified.

### Check Existing Images

```bash
aws ecr describe-images \
  --repository-name reliability-app \
  --region us-east-1
```

### Build and Push Image

Where no valid image existed, a new image was built and pushed:

```bash
docker build -t reliability-app:0.1.0 ./app

docker tag reliability-app:0.1.0 \
  <ecr-repository-url>:0.1.0

docker push <ecr-repository-url>:0.1.0
```

### Operational Lesson

An EKS deployment depends on a valid image existing in ECR.

If the image is missing, Pods cannot start and Deployments will not become available.

---

## Application Deployment

The application was deployed using Helm.

### Deploy Application

```bash
helm upgrade --install reliability-app \
  helm/reliability-app \
  -n reliability-lab \
  --create-namespace \
  -f helm/reliability-app/values-eks.yaml
```

### Validation

```bash
kubectl rollout status deployment/reliability-app -n reliability-lab

kubectl get pods -n reliability-lab
```

The deployment successfully reached the desired replica count before ingress configuration proceeded.

---

## AWS Load Balancer Controller

### Objective

The AWS Load Balancer Controller converts Kubernetes Ingress resources into AWS Application Load Balancers.

### Initial Issue

The controller could not authenticate to AWS and ingress provisioning failed.

Observed event:

```txt
FailedBuildModel

failed to refresh cached credentials

no EC2 IMDS role found
```

The controller attempted to use EC2 instance metadata rather than IAM Roles for Service Accounts (IRSA).

---

## IAM Role Creation

### Issue

The expected IAM role for the AWS Load Balancer Controller was not present.

Verification:

```bash
aws iam list-roles
```

returned no suitable Load Balancer Controller role.

### Resolution

A dedicated IAM role was created manually.

The role trust policy referenced:

```txt
system:serviceaccount:kube-system:aws-load-balancer-controller
```

and the cluster OIDC provider.

The AWS Load Balancer Controller IAM policy was attached to the role.

### Operational Lesson

Controller installation does not guarantee successful AWS authentication.

IAM role validation should be performed explicitly.

---

## Service Account Annotation Issue

### Issue

The ingress controller Service Account existed but was not correctly associated with the IAM role.

Verification:

```bash
kubectl get serviceaccount aws-load-balancer-controller \
  -n kube-system \
  -o yaml
```

showed that the required role annotation was missing.

### Resolution

The Service Account was annotated manually:

```bash
kubectl annotate serviceaccount \
  aws-load-balancer-controller \
  -n kube-system \
  eks.amazonaws.com/role-arn=<role-arn> \
  --overwrite
```

The controller deployment was restarted:

```bash
kubectl rollout restart deployment/aws-load-balancer-controller \
  -n kube-system
```

### Validation

Controller Pods were recreated and successfully obtained AWS credentials through IRSA.

---

## Ingress Deployment

### Helm Values

Ingress was enabled through:

```yaml
ingress:
  enabled: true
  className: alb
```

### Deployment

```bash
helm upgrade --install reliability-app \
  helm/reliability-app \
  -n reliability-lab \
  -f helm/reliability-app/values-eks.yaml
```

### Validation

```bash
kubectl get ingress -n reliability-lab

kubectl describe ingress reliability-app -n reliability-lab
```

The AWS Load Balancer Controller successfully provisioned an Application Load Balancer and populated the Ingress address.

---

## Monitoring Validation

Monitoring functionality was validated after ingress deployment.

Validation commands:

```bash
kubectl get pods -n monitoring

helm list -n monitoring
```

Prometheus and Grafana components remained healthy after ingress deployment.

---

## Evidence

Evidence captured in:

```txt
experiments/evidence/eks-ingress/
├── 01-lbc-deployment.txt
├── 02-lbc-pods.txt
├── 03-ingress.txt
├── 04-ingress-describe.txt
├── 05-service.txt
├── 06-alb-dns.txt
├── 07-healthz-via-alb.txt
├── 08-root-via-alb.json
├── 09-monitoring-pods.txt
└── 10-helm-list-all.txt
```

---

## Operational Findings

1. Terraform infrastructure provisioning must be validated before Kubernetes deployment begins.
2. ECR image availability must be verified before Helm deployment.
3. Application deployment should be confirmed healthy before ingress troubleshooting begins.
4. The AWS Load Balancer Controller depends on correct IAM and OIDC configuration.
5. Missing Service Account annotations prevent IRSA from functioning correctly.
6. Ingress troubleshooting should begin with controller events and authentication validation.
7. Successful ALB creation confirms correct interaction between Kubernetes, AWS IAM, IRSA, and AWS networking.

---

## Conclusion

This phase successfully transitioned the application from internal EKS deployment to production-style exposure through an AWS Application Load Balancer.

The implementation validated:

- Terraform infrastructure provisioning
- Amazon ECR image management
- Helm-based EKS deployment
- AWS Load Balancer Controller operation
- IAM Roles for Service Accounts (IRSA)
- ALB-backed Kubernetes Ingress
- Monitoring validation on EKS

The resulting architecture closely resembles the ingress model used in production Kubernetes environments running on Amazon EKS.

