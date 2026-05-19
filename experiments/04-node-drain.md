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

The reliability application Deployment was initially running 3 healthy replicas.

During testing, all application Pods were scheduled onto `reliability-lab-worker2`. No Pods were initially scheduled onto `reliability-lab-worker`.

This behaviour is expected because the Deployment did not yet define topology spread constraints or pod anti-affinity rules. Kubernetes does not guarantee even Pod distribution across nodes by default.

A node drain operation was executed against the worker node hosting the application Pods.

During the drain operation:

```txt
Pods entered Terminating state
replacement Pods were scheduled onto available nodes
new Pods transitioned through:
Pending → ContainerCreating → Running → Ready
```

The PodDisruptionBudget restricted voluntary disruption according to the configured policy:

```txt
minAvailable: 2
```

At least 2 application Pods remained available during the disruption event.

After the node drain completed, the worker node entered `SchedulingDisabled` state until it was restored using:

```bash
kubectl uncordon reliability-lab-worker2
```

Following uncordon, the node returned to `Ready` scheduling state.

No readiness probe failures or application crash loops were observed during the experiment.

## Conclusion

The experiment successfully validated PodDisruptionBudget behaviour during voluntary Kubernetes node disruption.

The configured PodDisruptionBudget protected minimum application availability while Kubernetes drained and rescheduled Pods from the affected worker node.

This demonstrated several important Kubernetes reliability concepts:

- controlled voluntary Pod eviction
- workload self-healing through Deployments
- Pod rescheduling during infrastructure maintenance
- interaction between node drain operations and PodDisruptionBudgets
- continued application availability during maintenance activity

The experiment also demonstrated that Kubernetes does not automatically distribute Pods evenly across nodes unless additional scheduling constraints are configured.

In a production AWS EKS environment, PodDisruptionBudgets are important during:

- managed node group upgrades
- cluster maintenance
- autoscaler scale-down operations
- node replacement activities

This experiment improved the overall reliability posture of the project by introducing disruption-aware workload protection.

