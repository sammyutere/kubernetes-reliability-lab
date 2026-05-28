# Alerting

## Purpose

This project uses Prometheus alerting rules to convert reliability signals into actionable operational alerts.

Metrics show system behaviour. Alerts define conditions that require operator attention.

## Implementation

Alert rules are defined in:

```txt
observability/alerts.yaml
```
Resource type:

```txt
PrometheusRule
```
Namespace:

```txt
monitoring
```
## Alerts

```txt
| Alert                                 | Purpose                                                 |
| ------------------------------------- | ------------------------------------------------------- |
| ReliabilityAppDeploymentUnavailable   | Detects fewer than 3 available app replicas             |
| ReliabilityAppPodRestarting           | Detects recent container restarts                       |
| ReliabilityAppHighCPUUsage            | Detects sustained high CPU usage                        |
| ReliabilityAppHpaNearMaxReplicas      | Detects HPA approaching maximum replica capacity        |
| ReliabilityAppPdbNoAllowedDisruptions | Detects when voluntary disruption is temporarily unsafe |
```
## Apply

```bash
kubectl apply -f observability/alerts.yaml
```
## Verify

```bash
kubectl get prometheusrule reliability-app-alerts -n monitoring
kubectl describe prometheusrule reliability-app-alerts -n monitoring
```
Prometheus UI:

```bash
kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring
```
Open:

```txt 
http://127.0.0.1:9090
```
Check:

```txt
Status → Rules
Alerts
```
## Test Alert

Scale the app below expected availability:

```bash
kubectl scale deployment reliability-app -n reliability-lab --replicas=1
```
Wait at least 2 minutes.

Check:

```txt
http://127.0.0.1:9090/alerts
```
Restore:

```bash
kubectl scale deployment reliability-app -n reliability-lab --replicas=3
helm upgrade --install reliability-app helm/reliability-app \
  -n reliability-lab \
  -f helm/reliability-app/values-local.yaml
```
## Evidence

Evidence is captured in:

```txt
experiments/evidence/alerts/
```
## Operational Notes

Manual scaling is acceptable for alert testing but creates temporary drift from Helm-managed desired state.

After testing, restore Helm desired state with:

```bash
helm upgrade --install reliability-app helm/reliability-app \
  -n reliability-lab \
  -f helm/reliability-app/values-local.yaml
```
## Alert Validation Notes

During local validation, `ReliabilityAppPdbNoAllowedDisruptions` fired successfully. This confirmed that PrometheusRule loading and alert evaluation were working.

`ReliabilityAppDeploymentUnavailable` did not fire during the initial local test attempts. This requires further investigation into the exact kube-state-metrics Deployment metric labels and the local failure condition used for testing.

The alert remains defined, but its validation status is currently marked as pending.

## Helm Field Ownership Conflict

During alert testing, the Deployment was manually modified using `kubectl patch` and `kubectl set image`.

A later Helm upgrade failed because Kubernetes server-side apply detected field ownership conflicts on:

- container image
- readiness probe path

The resolution was to delete the manually modified Deployment and reinstall it from the Helm chart.

Operational lesson:

When a workload is Helm-managed, avoid direct `kubectl patch` or `kubectl set` changes unless they are temporary and followed by a clean Helm reconciliation. Manual changes can create drift or field ownership conflicts.
