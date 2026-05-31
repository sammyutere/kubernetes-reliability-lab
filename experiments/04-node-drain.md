# Experiment: Node Drain with PodDisruptionBudget

## Purpose

Validate application behaviour during planned Kubernetes node maintenance.

## Hypothesis

When a worker node is drained, Kubernetes should evict Pods from that node, reschedule replacement Pods where possible, and respect the PodDisruptionBudget requiring at least 2 available reliability-app Pods.

## Preconditions

- Deployment `reliability-app` is healthy.
- Desired replica count is 3.
- Service `reliability-app` exists.
- PodDisruptionBudget `reliability-app-pdb` exists.
- At least one worker node is available for scheduling replacement Pods.

## Commands

Identify Pod placement:

```bash
kubectl get pods -n reliability-lab -o wide
```

Set target node:

```bash
DRAIN_NODE=reliability-lab-worker2
```

Drain node:

```bash
kubectl drain "$DRAIN_NODE" \
  --ignore-daemonsets \
  --delete-emptydir-data
```

Watch Pods:

```bash
kubectl get pods -n reliability-lab -o wide -w
```

Check PDB:

```bash
kubectl get pdb reliability-app-pdb -n reliability-lab
```

Restore node scheduling:

```bash
kubectl uncordon "$DRAIN_NODE"
```

## Expected Behaviour

- Target node enters `SchedulingDisabled`.
- App Pods on the drained node are evicted.
- Replacement Pods are scheduled on available nodes.
- The PDB limits voluntary disruption.
- The app Service remains available if enough Pods remain Ready.
- Node is restored after `kubectl uncordon`.

## Evidence

Evidence captured in:

```txt
experiments/evidence/node-drain/
├── 01-before-nodes.txt
├── 02-before-deployment.txt
├── 03-before-pods.txt
├── 04-before-pdb.txt
├── 05-during-nodes.txt
├── 06-during-pods.txt
├── 07-during-pdb.txt
├── 08-during-events.txt
├── 09-healthz-during-drain.json
├── 10-after-nodes.txt
├── 11-after-deployment.txt
├── 12-after-pods.txt
├── 13-after-pdb.txt
└── 14-after-events.txt
```

## Observed Behaviour

The reliability-app Deployment was healthy before the experiment.
Before the drain operation, all three reliability-app Pods were scheduled on the same worker node (`reliability-lab-worker2`).

This was possible because the workload did not define pod anti-affinity rules or topology spread constraints.

The node drain experiment therefore represented a more severe maintenance scenario because all application Pods required eviction and rescheduling during the operation.

A worker node containing application Pods was selected for drain.

During the drain operation, Kubernetes cordoned the node and began evicting eligible Pods.

The PodDisruptionBudget controlled the number of voluntary disruptions permitted during the maintenance operation.

Replacement Pods were created by the Deployment/ReplicaSet and scheduled on available nodes.

The Service remained the stable access point for the application, and the `/healthz` endpoint responded successfully during or after the drain validation.

After testing, the drained node was restored to normal scheduling state using `kubectl uncordon`.

No Kubernetes Events were returned in the `reliability-lab` namespace at the final evidence capture point. This is acceptable because Events are transient and may expire or be garbage-collected quickly in local clusters.

## Conclusion

The experiment successfully validated planned node maintenance behaviour in Kubernetes.

Node drain demonstrated the interaction between node scheduling, Pod eviction, Deployments, ReplicaSets, Services, and PodDisruptionBudgets.

This is directly relevant to production EKS operations because node drains occur during node replacement, managed node group upgrades, cluster maintenance, and autoscaler activity.

The experiment confirms that application availability during maintenance is not automatic; it depends on correct replica count, readiness behaviour, Service routing, and disruption budget configuration.
