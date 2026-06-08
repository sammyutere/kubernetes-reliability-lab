# Production Hardening

## Purpose

This milestone strengthens the EKS deployment by adding HTTPS, optional DNS, observability checks, and AWS cleanup verification.

## Environment Recovery Prerequisites

Before production hardening could begin, the AWS environment had been destroyed as part of a cost-management exercise.

The platform therefore had to be rebuilt before HTTPS, DNS, and observability validation could be performed.

The following recovery activities were completed:

- Terraform infrastructure recreated
- EKS cluster recreated
- kubeconfig reconfigured
- ECR repository validated
- Container image rebuilt and pushed
- Application redeployed
- Monitoring stack reinstalled
- AWS Load Balancer Controller reinstalled
- Ingress recreated

These activities restored the platform to a healthy baseline suitable for production hardening.

## AWS Load Balancer Controller Recovery

### Issue

The AWS Load Balancer Controller failed to start after infrastructure rebuild.

Observed errors included:

```txt
No OpenIDConnect provider found
failed to get VPC ID from instance metadata
failed to refresh cached credentials
no EC2 IMDS role found
```
## Root Causes

The following configuration issues were identified:

- Missing IAM OIDC provider
- Missing IAM role trust relationship
- Missing Service Account annotation
- Controller unable to determine VPC ID automatically

## Resolution

The following actions were performed:

- Associated EKS OIDC provider
- Recreated IAM role trust policy
- Annotated Service Account
- Reinstalled AWS Load Balancer Controller
- Supplied explicit VPC ID during installation

## Validation

The controller successfully deployed and the Ingress resource received an ALB hostname.

## HTTPS with ACM

The application can be secured with an ACM certificate attached to the ALB through Ingress annotations.

Required annotations:

```yaml
alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80},{"HTTPS":443}]'
alb.ingress.kubernetes.io/certificate-arn: <certificate-arn>
alb.ingress.kubernetes.io/ssl-redirect: '443'
```
## Optional Route 53 DNS

If a public hosted zone exists, a Route 53 alias record can point a custom hostname to the ALB.

## Observability Refinement

Validation includes:

- monitoring Pods running
- Prometheus queries working
- Grafana dashboards reviewed
- ingress and reliability objects captured as evidence

## Observability Validation Notes

During validation, Grafana dashboards initially displayed:

```txt
Failed to fetch
```
and some dashboards showed:

```txt
no data
```
Investigation confirmed:

- Grafana was operational
- Prometheus was operational
- Monitoring Pods were healthy
- Dashboard namespace filters required adjustment
- Additional scrape time was required before data became visible

These behaviours are common during initial monitoring deployment and do not necessarily indicate monitoring failure.


## Cost and Cleanup

Production-style exposure creates billable resources, especially the ALB.

Cleanup requires deleting Kubernetes resources that created AWS resources before running Terraform destroy.

Recommended cleanup order:

1. Delete Ingress
2. Uninstall application Helm release
3. Uninstall monitoring stack
4. Uninstall AWS Load Balancer Controller
5. Run Terraform destroy
6. Verify AWS resources are gone

## Evidence

Evidence is captured in:

```txt
experiments/evidence/production-hardening/
```
## Recovery Evidence

Environment rebuild evidence is stored in:

```txt
experiments/evidence/rebuild/
```
Contents include:

- Terraform outputs
- EKS node validation
- ECR image verification
- Application deployment validation
- Monitoring validation
- AWS Load Balancer Controller validation
- Ingress validation

