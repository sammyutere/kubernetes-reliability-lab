# Experiment: Kill a Pod

## Purpose

Validate Kubernetes self-healing behaviour when an application Pod is manually deleted.

## Hypothesis

If one reliability-app Pod is deleted, the Deployment should create a replacement Pod and restore the desired replica count.

## Preconditions

- Deployment `reliability-app` is running.
- Desired replica count is 3.
- Service `reliability-app` exists.
- Pods are healthy and Ready.

## Commands

Capture initial state:

```bash
kubectl get deployment reliability-app -n reliability-lab
kubectl get pods -n reliability-lab -o wide
kubectl get rs -n reliability-lab
```
Delete one Pod:

```bash
POD_NAME=$(kubectl get pods -n reliability-lab \
  -l app.kubernetes.io/name=reliability-app \
  -o jsonpath='{.items[0].metadata.name}')

kubectl delete pod "$POD_NAME" -n reliability-lab
```
Verify recovery:

```bash
kubectl rollout status deployment/reliability-app -n reliability-lab
kubectl get pods -n reliability-lab -o wide
kubectl get events -n reliability-lab --sort-by=.lastTimestamp
```
Test Service:

```bash
kubectl port-forward svc/reliability-app 8080:80 -n reliability-lab
curl -s http://127.0.0.1:8080/healthz
```
## Expected Behaviour

- The selected Pod enters Terminating.
- The ReplicaSet creates a replacement Pod.
- The new Pod moves through scheduling and startup phases.
- Deployment returns to 3 available replicas.
- Service remains usable after recovery.

## Evidence

Evidence captured in:

```txt
experiments/evidence/kill-pod/
├── 01-before-deployment.txt
├── 02-before-pods.txt
├── 03-before-replicasets.txt
├── 04-after-deployment.txt
├── 05-after-pods.txt
├── 06-events.txt
└── 07-healthz-after-delete.json
```
Observed Behaviour

The reliability-app Deployment was running with 3 desired replicas before the experiment.

One application Pod was manually deleted using kubectl delete pod.

Kubernetes immediately began terminating the selected Pod and created a replacement Pod through the Deployment's ReplicaSet.

The replacement Pod progressed through startup states and eventually reached Running and Ready.

After recovery, the Deployment returned to the desired state with 3 available replicas.

The Service continued to provide a stable access point to the application after the Pod replacement.

Conclusion

The experiment successfully validated Kubernetes self-healing behaviour for a Deployment-managed workload.

Deleting an individual Pod did not permanently reduce application capacity because the Deployment controller restored the declared replica count.

This demonstrates a core Kubernetes reliability principle: Pods are disposable, while controllers maintain desired state.

This behaviour is foundational for later reliability scenarios including rolling updates, node drains, autoscaling, and failure recovery in AWS EKS.


