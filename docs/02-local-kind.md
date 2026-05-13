# Local kind Cluster

## Purpose

This project uses kind to run a local multi-node Kubernetes cluster on Docker.

The local cluster allows Kubernetes workloads to be tested before deploying to AWS EKS.

## Cluster Shape

```txt
reliability-lab
├── control-plane
├── worker
└── worker2
```
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

## Load Local Image into kind

kind nodes run as Docker containers. A Docker image built on the host is not automatically available inside the Kubernetes nodes.

Build the image:

```bash
docker build -t reliability-app:local ./app
```
Load the image into kind:

```bash
kind load docker-image reliability-app:local --name reliability-lab
```
Verify image inside a node:

```bash
docker exec -it reliability-lab-worker crictl images | grep reliability-app
```
## Why this matters

Kubernetes does not build application images. It schedules Pods that reference already-built images.

For local kind clusters, images can be loaded directly into the cluster nodes.

For AWS EKS, images must be pushed to a registry such as Amazon ECR before worker nodes can pull them.
