# Kubernetes Fundamentals

## Kubernetes Mental Model

Kubernetes is a control plane for running containerised workloads.

Instead of manually starting containers, an engineer declares the desired state, and Kubernetes continuously works to make the actual state match it.

Example desired state:

```txt
Run 3 replicas of the reliability app.
Expose the app through a stable network endpoint.
Restart unhealthy containers.
Only send traffic to ready Pods.
```
## Core Objects

| Object     | Meaning                                     | Project Usage                                 |
| ---------- | ------------------------------------------- | --------------------------------------------- |
| Cluster    | A group of machines managed by Kubernetes   | Local kind cluster now; AWS EKS later         |
| Node       | A machine that runs workloads               | Docker container in kind; EC2 instance in EKS |
| Pod        | Smallest deployable unit in Kubernetes      | Will run the reliability-app container        |
| Deployment | Manages replicated Pods and rolling updates | Will keep app replicas running                |
| Service    | Stable network endpoint for Pods            | Will expose the app inside the cluster        |
| Ingress    | HTTP routing into the cluster               | Will expose the app externally later          |
| Namespace  | Logical isolation boundary                  | Will isolate reliability-lab resources        |
| ConfigMap  | Non-secret configuration                    | Will configure app environment                |
| Secret     | Sensitive configuration                     | Will hold sensitive values safely             |
| HPA        | Horizontal Pod Autoscaler                   | Will scale app replicas                       |
| PDB        | PodDisruptionBudget                         | Will protect availability during maintenance  |

## Docker vs Kubernetes

Docker answers:

```txt
How do I package and run one container?
```
Kubernetes answers:

```txt
How do I operate containers reliably across nodes?
```
## Kind

kind creates Kubernetes clusters using Docker containers as nodes.

In this project:

```txt
kind cluster = local Kubernetes practice environment
```
This allows Kubernetes behaviour to be tested before using AWS EKS.

## Kubectl

kubectl is the command-line client used to communicate with the Kubernetes API server.

Common commands:

```bash
kubectl get nodes
kubectl get pods -A
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl apply -f <file.yaml>
```
## Current Project Status

Completed so far:

- Built a FastAPI reliability app
- Added health, readiness, metrics, failure, latency, and CPU endpoints
- Containerised the app with Docker
- Created a local multi-node kind cluster
- Loaded the local Docker image into kind

Next:

- Create a Namespace
- Create a Deployment
- Run the app as Kubernetes Pods
- Expose the app through a Service

## Namespace Implementation

The project uses a dedicated namespace:

```txt
reliability-lab
This keeps application resources separate from Kubernetes system resources and future environments.
```
The namespace is defined declaratively in:

```bash
k8s/base/namespace.yaml
```
Apply it with:

```bash
kubectl apply -f k8s/base/namespace.yaml
```
Use it as the default namespace for the current kubectl context:

```bash
kubectl config set-context --current --namespace=reliability-lab
```
Verify:

```bash
kubectl get namespace reliability-lab --show-labels
kubectl get all
```

## Deployment Implementation

The reliability app is deployed with a Kubernetes Deployment:

```txt
k8s/base/deployment.yaml
The Deployment declares:

- 3 desired replicas
- container image reliability-app:local
- local image pull policy
- HTTP container port 8000
- readiness probe
- liveness probe
- CPU and memory requests
- CPU and memory limits
```
Apply it:

```bash
kubectl apply -f k8s/base/deployment.yaml
```
Check rollout:

```bash
kubectl rollout status deployment/reliability-app -n reliability-lab
```
Inspect Pods:

```bash
kubectl get pods -n reliability-lab -o wide
kubectl describe pod <pod-name> -n reliability-lab
kubectl logs deployment/reliability-app -n reliability-lab
```
Test self-healing:

```bash
kubectl delete pod -l app.kubernetes.io/name=reliability-app -n reliability-lab
kubectl get pods -n reliability-lab -w
```
## Deployment Mental Model

A Deployment does not directly run the app. It creates and manages ReplicaSets, and ReplicaSets manage Pods.

```txt
Deployment
└── ReplicaSet
    ├── Pod
    ├── Pod
    └── Pod
```
Each Pod runs the reliability-app container.

## Service Implementation

The reliability app is exposed inside the cluster through a Kubernetes Service:

```txt
k8s/base/service.yaml
The Service is a ClusterIP Service.
This means it is reachable inside the Kubernetes cluster but not directly from outside the cluster.
```
Apply it:

```bash
kubectl apply -f k8s/base/service.yaml
```
Verify it:

```bash
kubectl get svc -n reliability-lab
kubectl describe svc reliability-app -n reliability-lab
kubectl get endpoints reliability-app -n reliability-lab
```
Access it locally with port-forwarding:

```bash
kubectl port-forward svc/reliability-app 8080:80 -n reliability-lab
```
Then test:

```bash
curl http://127.0.0.1:8080/healthz
curl http://127.0.0.1:8080/readyz
curl http://127.0.0.1:8080/metrics
```
## Service Mental Model

Pods are disposable and receive changing IP addresses.

A Service gives a stable endpoint in front of those Pods.

```txt
Client
  ↓
Service: reliability-app
  ↓
Endpoints
  ↓
Pods
  ↓
Container port 8000
```
The Service uses labels to find matching Pods.

In this project, it selects Pods with:

```txt
app.kubernetes.io/name=reliability-app
```
