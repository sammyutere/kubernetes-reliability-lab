# Helm Packaging

## Purpose

This project uses Helm to package Kubernetes resources into a reusable, parameterised application release.

Helm allows the same application chart to be deployed to different environments using different values files.

## Chart Location

```txt
helm/reliability-app
```
## Main Files

| File                | Purpose                               |
| ------------------- | ------------------------------------- |
| `Chart.yaml`        | Chart metadata                        |
| `values.yaml`       | Default configuration                 |
| `values-local.yaml` | Local kind overrides                  |
| `values-eks.yaml`   | EKS placeholder overrides             |
| `templates/`        | Kubernetes manifests rendered by Helm |

## Local Install

```bash
helm upgrade --install reliability-app helm/reliability-app \
  -n reliability-lab \
  --create-namespace \
  -f helm/reliability-app/values-local.yaml
```
## Validation

```bash
helm lint helm/reliability-app
helm template reliability-app helm/reliability-app \
  -n reliability-lab \
  -f helm/reliability-app/values-local.yaml
helm status reliability-app -n reliability-lab
```
## Operational Model

```text
values.yaml
    ↓
Helm templates
    ↓
Rendered Kubernetes manifests
    ↓
Kubernetes API
    ↓
Deployment, Service, ConfigMap, HPA, PDB, NetworkPolicy
```
## Helm Ownership and Existing Resources

During initial Helm installation, the release failed because several Kubernetes resources had already been created manually using `kubectl apply`.

Example error:

```txt
invalid ownership metadata;
label validation error:
key "app.kubernetes.io/managed-by" must equal "Helm":
current value is "kubectl"
```

The following resources already existed in the cluster:

- Deployment
- Service
- ConfigMap
- HorizontalPodAutoscaler
- PodDisruptionBudget
- NetworkPolicy

Helm refused to take ownership of these existing resources because they were originally managed outside Helm.

To allow Helm to manage the application release cleanly, the manually-created resources were deleted before reinstalling the chart.

Commands used:

```bash
kubectl delete networkpolicy reliability-app-ingress-policy -n reliability-lab
kubectl delete hpa reliability-app-hpa -n reliability-lab
kubectl delete pdb reliability-app-pdb -n reliability-lab
kubectl delete service reliability-app -n reliability-lab
kubectl delete deployment reliability-app -n reliability-lab
kubectl delete configmap reliability-app-config -n reliability-lab
```

The Kubernetes Secret was intentionally preserved:

```bash
kubectl get secret reliability-app-secret -n reliability-lab
```

After cleanup, the Helm release installed successfully:

```bash
helm upgrade --install reliability-app helm/reliability-app \
  -n reliability-lab \
  --create-namespace \
  -f helm/reliability-app/values-local.yaml
```

## Operational Lesson

Helm manages Kubernetes resources using release ownership metadata.

Resources created manually with `kubectl apply` are not automatically adopted into a Helm release.

This is an important operational consideration when migrating manually-managed Kubernetes resources into Helm-managed deployments.

## Why Helm Matters

Static Kubernetes YAML is useful for learning. Helm is stronger for repeatable deployments because configuration can be externalised into values files.

This prepares the project for EKS, CI/CD, environment-specific configuration, and release rollback workflows.

