# Experiment: Node Drain with PodDisruptionBudget

## Purpose

Validate that the reliability app maintains minimum availability during voluntary node maintenance.

## Hypothesis

With 3 replicas and a PodDisruptionBudget requiring `minAvailable: 2`, Kubernetes should allow at most 1 voluntary Pod disruption at a time.

## Preconditions

- Deployment `reliability-app` is running 3 replicas.
- Service `reliability-app` is available.
- PodDisruptionBudget `reliability-app-pdb` exists.
- All Pods are healthy and Ready.

## Commands

Check current Pods:

```bash
kubectl get pods -n reliability-lab -o wide
```
Check PDB:

```bash
kubectl get pdb -n reliability-lab
```
Drain worker node:

```bash
kubectl drain reliability-lab-worker --ignore-daemonsets --delete-emptydir-data
```
Watch Pods:

```bash
kubectl get pods -n reliability-lab -o wide -w
```
Restore node scheduling:

```bash
kubectl uncordon reliability-lab-worker
```
## Expected Behaviour

- Pods on the drained node are evicted.
- Kubernetes creates replacement Pods.
- At least 2 app Pods should remain available during voluntary disruption.
- The PDB should prevent too many simultaneous voluntary evictions.

## Evidence Capture

Record:

```bash
kubectl get pods -n reliability-lab -o wide
kubectl get pdb -n reliability-lab
kubectl describe pdb reliability-app-pdb -n reliability-lab
kubectl get nodes
```
## Observed Behaviour

During local kind testing, all reliability-app Pods were initially scheduled on reliability-lab-worker2. This is expected because the Deployment did not yet define topology spread constraints or pod anti-affinity. Kubernetes does not guarantee even Pod distribution by default.

To be completed fully during experiment execution.

## Conclusion

To be completed after experiment execution.
