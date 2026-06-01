# Runbooks

## Purpose

Runbooks provide repeatable operational procedures for diagnosing and recovering from known reliability issues in this lab.

They convert experiment findings into practical operating instructions.

---

## Runbook: Failed Application Rollout

### Symptoms

- New Pods show `ErrImagePull` or `ImagePullBackOff`.
- `kubectl rollout status` times out.
- Deployment does not reach expected available replicas.
- Events show image pull failures.

### Investigation

```bash
kubectl get deployment reliability-app -n reliability-lab
kubectl get pods -n reliability-lab -o wide
kubectl describe deployment reliability-app -n reliability-lab
kubectl get events -n reliability-lab --sort-by=.lastTimestamp
helm history reliability-app -n reliability-lab
```
## Identify Last Known Good Release

Inspect Helm history:

```bash
helm history reliability-app -n reliability-lab
```
A suitable rollback target is usually the most recent successfully deployed revision.

## Recovery Option 1: Helm rollback

```bash
helm rollback reliability-app <previous-good-revision> -n reliability-lab
kubectl rollout status deployment/reliability-app -n reliability-lab
```
If the rollback does not restore a healthy Deployment and rollout status reports:

```txt
deployment exceeded its progress deadline
```
proceed to Recovery Option 2.

## Recovery Option 2: Reapply Known-Good Helm Configuration

```bash
helm upgrade --install reliability-app \
  helm/reliability-app \
  -n reliability-lab \
  -f helm/reliability-app/values-local.yaml

kubectl rollout status deployment/reliability-app -n reliability-lab
kubectl get pods -n reliability-lab
```
This recovery path was successfully validated during the bad rollout experiment.

## Validation

```bash
kubectl get deployment reliability-app -n reliability-lab
kubectl get pods -n reliability-lab
kubectl port-forward svc/reliability-app 8080:80 -n reliability-lab
curl http://127.0.0.1:8080/healthz
```
## Prevention

Use CI to validate image references before deployment.
Use immutable image tags.
Avoid deploying untested image references.
Keep Helm rollback and known-good upgrade workflows documented.

# Runbook: Planned Node Drain
## Use Case

A Kubernetes node needs to be removed from service for maintenance, upgrade, or replacement.

## Pre-checks

```bash
kubectl get nodes
kubectl get pods -n reliability-lab -o wide
kubectl get pdb reliability-app-pdb -n reliability-lab
kubectl get deployment reliability-app -n reliability-lab
```
## Drain

```bash
DRAIN_NODE=reliability-lab-worker2

kubectl drain "$DRAIN_NODE" \
  --ignore-daemonsets \
  --delete-emptydir-data
```
## Validate

```bash
kubectl get nodes
kubectl get pods -n reliability-lab -o wide
kubectl get pdb reliability-app-pdb -n reliability-lab
kubectl port-forward svc/reliability-app 8080:80 -n reliability-lab
curl http://127.0.0.1:8080/healthz
```
## Restore Scheduling

```bash
kubectl uncordon "$DRAIN_NODE"
```
## Operational Notes

- PDBs protect against excessive voluntary disruption.
- PDBs do not protect against all involuntary failures.
- A node should be uncordoned after maintenance if it will remain part of the cluster.
- Pod placement should be reviewed before draining nodes.

# Runbook: HPA Not Scaling

## Symptoms

- HPA exists but replicas remain at minimum.
- HPA output shows low CPU usage, for example cpu: 2%/50%.
- Load test does not produce scale-up.

## Investigation

```bash
kubectl get hpa reliability-app-hpa -n reliability-lab
kubectl describe hpa reliability-app-hpa -n reliability-lab
kubectl top pods -n reliability-lab
kubectl get deployment reliability-app -n reliability-lab
```
## Common Causes

- CPU load is too low.
- HPA threshold is too high for local test conditions.
- CPU requests are not configured correctly.
- Metrics Server is not returning current metrics.
- Local machine has enough CPU headroom that the test does not create pressure.

## Local Test Adjustment

For local kind validation, reduce the HPA target and increase load-test concurrency.

If Helm conflicts with HPA replica ownership:

```bash
kubectl delete hpa reliability-app-hpa -n reliability-lab

helm upgrade --install reliability-app \
  helm/reliability-app \
  -n reliability-lab \
  -f helm/reliability-app/values-local.yaml
```
## Validate

```bash
kubectl get hpa reliability-app-hpa -n reliability-lab -w
kubectl get pods -n reliability-lab -w
```
# Runbook: Prometheus Alert Not Firing
## Symptoms

- PrometheusRule exists.
- Alert does not appear in Prometheus UI.
- Only some alerts fire.

## Investigation

```bash
kubectl get prometheusrule -n monitoring
kubectl get prometheusrule reliability-app-alerts -n monitoring -o yaml
kubectl get prometheus monitoring-kube-prometheus-prometheus -n monitoring -o yaml | grep -A10 ruleSelector
```
Check Prometheus:

```txt
http://127.0.0.1:9090/rules
http://127.0.0.1:9090/alerts
```
## Operational Notes

During local validation, ReliabilityAppPdbNoAllowedDisruptions fired successfully, proving that PrometheusRule loading and alert evaluation worked.

ReliabilityAppDeploymentUnavailable did not fire during the initial local tests and remains a validation item for later refinement.

