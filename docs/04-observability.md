# Observability

## Purpose

This project uses Prometheus and Grafana to observe Kubernetes cluster health, workload behaviour, and application reliability signals.

## Monitoring Stack

Installed with:

```txt
prometheus-community/kube-prometheus-stack
```
Namespace:

```txt
monitoring
```
## Components

```txt
| Component           | Purpose                                   |
| ------------------- | ----------------------------------------- |
| Prometheus          | Metrics collection, storage, and querying |
| Grafana             | Dashboards and visualisation              |
| Alertmanager        | Alert routing and notification handling   |
| kube-state-metrics  | Kubernetes object state metrics           |
| node-exporter       | Node-level system metrics                 |
| Prometheus Operator | Manages Prometheus custom resources       |
```
## Install

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --create-namespace \
  -f observability/prometheus-values.yaml
```
## Verify

```bash
helm list -n monitoring
helm status monitoring -n monitoring
kubectl get pods -n monitoring
kubectl get svc -n monitoring
```
## Access Grafana

```bash
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring
```
Open:

```txt
http://127.0.0.1:3000
```
Local credentials:

```txt
username: admin
password: admin
```
## Access Prometheus

```bash
kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring
```
Open:

```txt
http://127.0.0.1:9090
```
## Evidence

Evidence is captured in:

```bash
experiments/evidence/observability/
```
## Operational Notes

Prometheus provides metrics collection and query capability.

Grafana provides visual dashboards.

This observability layer will later support alerting, SLO measurement, reliability experiments, and EKS operational validation.

## Alerting Layer

Prometheus alerting rules are defined using the Prometheus Operator `PrometheusRule` resource.

Alert manifest:

```txt
observability/alerts.yaml
```
The current alert set covers:

- Deployment availability
- Pod restarts
- high CPU usage
- HPA near maximum replicas
- PDB with no allowed disruptions

Alerting converts raw metrics into operational signals that require investigation or action.

## Autoscaling Observability

Autoscaling experiments should capture evidence before, during, and after load generation.

Useful commands:

```bash
kubectl top pods -n reliability-lab

kubectl get hpa reliability-app-hpa -n reliability-lab

kubectl describe hpa reliability-app-hpa -n reliability-lab
```
### Monitoring CPU Usage

Some kubectl versions do not support:

```bash
kubectl top pods --watch
```

For compatibility, use:

```bash
while true; do
  clear
  kubectl top pods -n reliability-lab
  sleep 5
done
```
### Local Environment Considerations

A powerful local workstation may not generate sufficient CPU pressure to trigger autoscaling using production-oriented HPA thresholds.

Local validation may require:

- lower target utilisation
- longer test duration
- higher concurrency
- more CPU-intensive workloads

Evidence should always determine conclusions rather than assumptions.

