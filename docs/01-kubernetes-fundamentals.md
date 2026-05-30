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

## ConfigMap Implementation

The project uses a ConfigMap to provide non-secret runtime configuration to the reliability app.

Manifest:

```txt
k8s/base/configmap.yaml
```
The ConfigMap currently provides:

```txt
APP_NAME
APP_VERSION
APP_ENV
LOG_LEVEL
```
The Deployment consumes the ConfigMap using:

```yaml
envFrom:
  - configMapRef:
      name: reliability-app-config
```
Apply it:

```bash
kubectl apply -f k8s/base/configmap.yaml
kubectl apply -f k8s/base/deployment.yaml
```
Verify:

```bash
kubectl describe configmap reliability-app-config -n reliability-lab
kubectl port-forward svc/reliability-app 8080:80 -n reliability-lab
curl -s http://127.0.0.1:8080/ | jq
```
Important operational note:

When a ConfigMap is consumed as environment variables, existing Pods do not automatically receive updated values. Restart the Deployment to roll out the new configuration:

```bash
kubectl rollout restart deployment/reliability-app -n reliability-lab
```


## Secret Implementation

The project uses a Kubernetes Secret to demonstrate sensitive runtime configuration.

Example manifest:

```txt
k8s/base/secret.example.yaml
```
Local real secret file:

```txt
k8s/base/secret.local.yaml
```
The local file is ignored by Git and must not be committed.

The Deployment consumes the Secret using:

```yaml
envFrom:
  - secretRef:
      name: reliability-app-secret
```
Apply local secret:

```bash
kubectl apply -f k8s/base/secret.local.yaml
```
Verify:

```bash
kubectl get secret reliability-app-secret -n reliability-lab
kubectl describe secret reliability-app-secret -n reliability-lab
```
Operational rule:

Never commit real credentials to Git. Commit only example secret manifests with placeholder values.

## PodDisruptionBudget Implementation

The project uses a PodDisruptionBudget to protect app availability during voluntary disruption.

Manifest:

```txt
k8s/base/pdb.yaml
```
Current policy:

```txt
minAvailable: 2
```
This means at least 2 matching Pods should remain available during voluntary disruptions.

Apply it:

```bash
kubectl apply -f k8s/base/pdb.yaml
```
Verify:

```bash
kubectl get pdb -n reliability-lab
kubectl describe pdb reliability-app-pdb -n reliability-lab
```
Test with node drain:

```bash
kubectl drain reliability-lab-worker --ignore-daemonsets --delete-emptydir-data
kubectl get pods -n reliability-lab -o wide -w
kubectl uncordon reliability-lab-worker
```
## PDB Mental Model

A PDB does not keep Pods alive during crashes.

It controls voluntary evictions.

Examples of voluntary disruptions:

- node drain
- node upgrades
- cluster maintenance
- autoscaler scale-down

Examples not protected by PDB:

- application crash
- node hardware failure
- kernel panic
- out-of-memory kill

## HorizontalPodAutoscaler Implementation

The project uses a HorizontalPodAutoscaler to scale the reliability app based on CPU utilisation.

Manifest:

```txt
k8s/base/hpa.yaml
```
Current policy:

```txt
minReplicas: 3
maxReplicas: 8
target average CPU utilisation: 50%
```
The HPA targets:

```txt
Deployment/reliability-app
```
Apply it:

```bash
kubectl apply -f k8s/base/hpa.yaml
```
Verify:

```bash
kubectl get hpa -n reliability-lab
kubectl describe hpa reliability-app-hpa -n reliability-lab
```
Metrics Server is required for CPU and memory resource metrics:

```bash
kubectl top nodes
kubectl top pods -n reliability-lab
```
## HPA Mental Model

The HPA does not create nodes. It changes the replica count of a workload.

```txt
HPA
  ↓ adjusts replicas
Deployment
  ↓ creates/removes Pods
ReplicaSet
  ↓ manages Pods
Pods
```
CPU-based HPA depends on resource requests. Without CPU requests, Kubernetes cannot calculate utilisation percentages reliably.


## NetworkPolicy Implementation

The project uses a Kubernetes NetworkPolicy to define allowed ingress traffic to the reliability app.

Manifest:

```txt
k8s/base/networkpolicy.yaml
```
Policy intent:

```txt
Allow inbound TCP traffic to reliability-app Pods on port 8000 only from Pods labelled access=allowed.
```
Apply it:

```bash
kubectl apply -f k8s/base/networkpolicy.yaml
```
Verify it:

```bash
kubectl get networkpolicy -n reliability-lab
kubectl describe networkpolicy reliability-app-ingress-policy -n reliability-lab
```
Important operational note:

NetworkPolicy resources require a compatible CNI implementation to enforce them. A Kubernetes API server may accept the resource even if the cluster networking layer does not enforce the rules.

## CPU Spike and HorizontalPodAutoscaler Experiment

The project includes a CPU spike experiment to validate autoscaling behaviour.

### Components Involved

```txt
Load Generator
    ↓
Application CPU Usage
    ↓
Metrics Server
    ↓
HorizontalPodAutoscaler
    ↓
Deployment
    ↓
ReplicaSet
    ↓
Pods
```

### Operational Findings

Initial testing did not trigger autoscaling because CPU utilisation remained below the configured threshold.

Observed HPA metric:

```txt
cpu: 2%/50%
```

To improve observability in the local kind environment:

- CPU target utilisation was reduced to 10%.
- Load-test concurrency was increased.
- Additional evidence capture was introduced.

### Helm and HPA Interaction

During HPA tuning, Helm upgrade initially failed because Deployment replica count was being managed by the HPA controller.

The HPA was temporarily removed before reapplying the Helm configuration.

This demonstrated an important operational consideration when multiple controllers interact with Deployment scaling behaviour.

### Learning Outcome

The experiment validated:

- Metrics collection
- Autoscaling evaluation
- Deployment scaling logic
- HPA ownership behaviour
- Local environment limitations

