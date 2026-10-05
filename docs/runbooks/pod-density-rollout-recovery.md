# Runbook — Kubernetes Rollout Stalled by Pod-Density Exhaustion

## Trigger

Use this runbook when:

- Deployments exceed their progress deadline
- replacement Pods remain Pending
- scheduler events report `Too many pods`

## Diagnose

```bash
kubectl get pods -n reliability-lab -o wide
```

```bash
kubectl get events \
  -n reliability-lab \
  --sort-by=.lastTimestamp \
  | tail -80
```

```bash
kubectl get nodes \
  -o custom-columns='NODE:.metadata.name,ALLOCATABLE_PODS:.status.allocatable.pods'
```

```bash
for node in $(kubectl get nodes -o name | cut -d/ -f2); do
  echo
  echo "=== $node ==="
  printf "Allocatable Pods: "
  kubectl get node "$node" \
    -o jsonpath='{.status.allocatable.pods}{"\n"}'
  printf "Scheduled Pods: "
  kubectl get pods \
    -A \
    --field-selector spec.nodeName="$node" \
    --no-headers \
    | wc -l
done
```

## Recovery

Use Terraform for infrastructure capacity changes:

```bash
cd terraform/environments/dev
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan-capacity
terraform show -no-color tfplan-capacity
terraform apply tfplan-capacity
rm -f tfplan-capacity
cd ../../..
```

Watch nodes:

```bash
kubectl get nodes -w
```

Then monitor application Pods:

```bash
kubectl get pods -n reliability-lab -w
```

## Validate Recovery

```bash
for deployment in frontend api dependency; do
  kubectl rollout status \
    deployment/$deployment \
    -n reliability-lab \
    --timeout=600s
done
```

```bash
kubectl get applications \
  -n argocd \
  -o custom-columns='NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status'
```

## Do Not

Do not use these as the capacity fix:

```text
kubectl set image
kubectl rollout undo
helm upgrade
manual Pod deletion
manual AWS console scaling
```

Application desired state remains Git-owned and infrastructure remains Terraform-owned.
