# Runbooks

## Runbook: Failed Application Rollout

### Symptoms

- New Pods show `ErrImagePull` or `ImagePullBackOff`.
- `kubectl rollout status` times out.
- Deployment does not reach expected available replicas.
- Events show image pull failures.

### Investigation

### Identify Last Known Good Release

Inspect Helm history:

```bash
helm history reliability-app -n reliability-lab
```

Example:

```txt
REVISION STATUS
1        superseded
2-4      failed
5-6      superseded
7        deployed
```
The most recent revision with status `deployed` should normally be considered the primary rollback target.

```bash
kubectl get deployment reliability-app -n reliability-lab
kubectl get pods -n reliability-lab -o wide
kubectl describe deployment reliability-app -n reliability-lab
kubectl get events -n reliability-lab --sort-by=.lastTimestamp
helm history reliability-app -n reliability-lab
```
## Recovery Option 1: Helm rollback

```bash
helm history reliability-app -n reliability-lab
helm rollback reliability-app <previous-good-revision> -n reliability-lab
kubectl rollout status deployment/reliability-app -n reliability-lab
```
If the rollback does not restore a healthy Deployment and rollout status reports:

deployment exceeded its progress deadline

proceed to Recovery Option 2.

## Recovery Option 2: Reapply Known-Good Helm Configuration

```bash
helm upgrade --install reliability-app helm/reliability-app \
  -n reliability-lab \
  -f helm/reliability-app/values-local.yaml

kubectl rollout status deployment/reliability-app -n reliability-lab
```
## Validation

```bash
kubectl get deployment reliability-app -n reliability-lab
kubectl get pods -n reliability-lab
kubectl port-forward svc/reliability-app 8080:80 -n reliability-lab
curl http://127.0.0.1:8080/healthz
```
## Prevention

- Use CI to validate image existence before deployment.
- Use immutable image tags.
- Avoid deploying untested image references.
- Keep Helm rollback workflow documented.

## Runbook: Planned Node Drain

### Symptoms / Use Case

A Kubernetes node needs to be removed from service for maintenance, upgrade, or replacement.

### Pre-checks

```bash
kubectl get nodes
kubectl get pods -n reliability-lab -o wide
kubectl get pdb reliability-app-pdb -n reliability-lab
kubectl get deployment reliability-app -n reliability-lab
```
## Drain

```bash
DRAIN_NODE=reliability-lab-worker2

kubectl drain "$DRAIN_NODE" \
  --ignore-daemonsets \
  --delete-emptydir-data
```
## Validate

```bash
kubectl get nodes
kubectl get pods -n reliability-lab -o wide
kubectl get pdb reliability-app-pdb -n reliability-lab
kubectl port-forward svc/reliability-app 8080:80 -n reliability-lab
curl http://127.0.0.1:8080/healthz
```
## Restore Scheduling

```bash
kubectl uncordon "$DRAIN_NODE"
```
## Operational Notes

- PDBs protect against excessive voluntary disruption.
- PDBs do not protect against all involuntary failures.
- A node should be uncordoned after maintenance if it will remain part of the cluster.
