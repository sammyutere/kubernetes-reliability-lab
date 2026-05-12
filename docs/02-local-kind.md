# Local kind Cluster

## Purpose

This project uses kind to run a local multi-node Kubernetes cluster on Docker.

The local cluster allows Kubernetes workloads to be tested before deploying to AWS EKS.

## Cluster Shape

reliability-lab
├── control-plane
├── worker
└── worker2

## Create Cluster

```bash
kind create cluster --config k8s/kind-config.yaml
```
## Verify Cluster

```bash
kind get clusters
kubectl config current-context
kubectl get nodes
kubectl get pods -A
```
## Cleanup

```bash
kind delete cluster --name reliability-lab
```
