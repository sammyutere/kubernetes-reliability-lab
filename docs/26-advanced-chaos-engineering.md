# Phase 13 — Advanced Chaos Engineering and Resilience Validation

## Objective

Validate platform resilience through controlled failure scenarios while measuring operational recovery performance.

This phase demonstrates that:

- Services can withstand controlled failure conditions.
- Monitoring and alerting remain operational during incidents.
- Recovery procedures can be executed successfully.
- Mean Time To Recovery (MTTR) can be measured and documented.
- Reliability governance continues to function during failures.

---

# Relationship to the Overall Project

Previous phases established:

```txt
Infrastructure
    ↓
Kubernetes Reliability
    ↓
Observability
    ↓
SLO Governance
    ↓
Progressive Delivery
```

This phase validates whether those controls remain effective during failure.

```txt
Controlled Failure
        ↓
Detection
        ↓
Alerting
        ↓
Recovery
        ↓
MTTR Measurement
        ↓
Reliability Scorecard
```

---

# Architecture Under Test

```txt
Frontend
   ↓
API
   ↓
Dependency
```

Failure domains:

- Frontend latency
- API degradation
- Dependency failure
- Resource exhaustion
- Alerting failures
- Recovery workflows

---

# Part 0 — Environment Recovery After AWS Cleanup

## Objective

Rebuild all required cloud resources after infrastructure destruction.

### Recreate Infrastructure

```bash
cd terraform/environments/dev

terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Capture evidence:

```bash
terraform show -no-color tfplan \
> ../../../experiments/evidence/advanced-chaos/00-terraform-plan.txt

terraform output \
> ../../../experiments/evidence/advanced-chaos/01-terraform-output.txt
```

---

### Reconnect to EKS

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name reliability-lab-dev

kubectl get nodes -o wide
```

Capture:

```bash
kubectl get nodes -o wide \
> experiments/evidence/advanced-chaos/02-eks-nodes.txt
```

---

### Recreate Namespaces

```bash
kubectl create namespace reliability-lab \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create namespace monitoring \
  --dry-run=client -o yaml | kubectl apply -f -
```

---

### Reinstall Monitoring

```bash
helm upgrade --install monitoring \
  prometheus-community/kube-prometheus-stack \
  -n monitoring
```

Verify:

```bash
kubectl get pods -n monitoring
```

Capture:

```bash
kubectl get pods -n monitoring \
> experiments/evidence/advanced-chaos/03-monitoring-pods.txt
```

---

### Redeploy Application

Redeploy:

- frontend
- api
- dependency

Verify:

```bash
kubectl get deployments,svc,pods \
  -n reliability-lab
```

Capture:

```bash
kubectl get deployments,svc,pods,hpa,pdb \
  -n reliability-lab -o wide \
> experiments/evidence/advanced-chaos/04-app-baseline.txt
```

---

# Part 1 — Apply Reliability Governance

Apply previously created governance rules:

```bash
kubectl apply -f observability/reliability-governance-rules.yaml
```

Verify:

```bash
kubectl get prometheusrule -n monitoring
```

Capture:

```bash
kubectl get prometheusrule -n monitoring \
> experiments/evidence/advanced-chaos/05-prometheus-rules.txt
```

---

# Part 2 — Chaos Experiment: Dependency Latency

Inject latency:

```bash
kubectl set env deployment/dependency \
  -n reliability-lab \
  LATENCY_MS=1500
```

Generate traffic.

Observe:

- latency
- success ratio
- error ratio

Record:

- failure start
- recovery start
- recovery complete

Restore:

```bash
kubectl set env deployment/dependency \
  -n reliability-lab \
  LATENCY_MS=0
```

---

# Part 3 — Chaos Experiment: Partial Service Outage

Reduce dependency capacity:

```bash
kubectl scale deployment dependency \
  -n reliability-lab \
  --replicas=1
```

Generate traffic.

Observe:

- latency
- success ratio
- error ratio
- alert behaviour

Restore:

```bash
kubectl scale deployment dependency \
  -n reliability-lab \
  --replicas=2
```

---

# Part 4 — Chaos Experiment: Resource Exhaustion

Create CPU pressure workload.

```bash
kubectl apply -f k8s/chaos-cpu-stress.yaml
```

Observe:

- node pressure
- pod scheduling
- HPA behaviour

Capture:

```bash
kubectl get hpa -n reliability-lab
```

---

## Operational Observation

After environment reconstruction:

```txt
kubectl get hpa -n reliability-lab
```

returned:

```txt
No resources found in reliability-lab namespace
```

This occurred because HPA resources were not recreated automatically after infrastructure rebuild.

HPAs were recreated manually:

```bash
kubectl autoscale deployment frontend \
  -n reliability-lab \
  --cpu-percent=60 \
  --min=2 \
  --max=6

kubectl autoscale deployment api \
  -n reliability-lab \
  --cpu-percent=60 \
  --min=2 \
  --max=6

kubectl autoscale deployment dependency \
  -n reliability-lab \
  --cpu-percent=60 \
  --min=2 \
  --max=6
```

Lesson:

```txt
Environment recovery must include
validation of autoscaling resources.
```

---

# Part 5 — Alert Routing Validation

Trigger dependency failures:

```bash
kubectl set env deployment/dependency \
  -n reliability-lab \
  FAILURE_MODE=error
```

Generate traffic.

Verify:

- Prometheus alerts
- Alertmanager routing
- alert severity mapping

Restore:

```bash
kubectl set env deployment/dependency \
  -n reliability-lab \
  FAILURE_MODE=none
```

---

# Part 6 — MTTR Measurement

Measure:

| Scenario            | MTTR     |
| ------------------- | -------- |
| Latency injection   | Recorded |
| Partial outage      | Recorded |
| Resource exhaustion | Recorded |
| Dependency failure  | Recorded |

Store:

```txt
experiments/evidence/advanced-chaos/24-mttr-summary.md
```

---

# Part 7 — Reliability Scorecard Update

Port-forward Prometheus:

```bash
kubectl port-forward \
  svc/monitoring-kube-prometheus-prometheus \
  9090:9090 \
  -n monitoring
```

Generate traffic.

Run:

```bash
./scripts/reliability-scorecard.sh
```

Store:

```txt
experiments/evidence/advanced-chaos/25-reliability-scorecard-after-chaos.md
```

---

## Operational Observation

The initial scorecard generation failed:

```txt
JSONDecodeError
```

Root cause:

Prometheus was not returning JSON to the scorecard script.

Most likely cause:

```txt
Prometheus port-forward was not active.
```

Resolution:

- Start Prometheus port-forward.
- Verify Prometheus API response.
- Re-run scorecard generation.

Lesson:

```txt
Operational dependencies
must be validated before
automation execution.
```

---

# Part 8 — Key Reliability Lessons

## Latency Is A Failure Mode

Users experience latency as failure.

Latency testing is therefore as important as outage testing.

---

## Capacity Matters

Partial outages validate:

- redundancy
- scaling
- resource allocation

---

## Monitoring Must Survive Failure

Observability systems are part of the production platform.

Monitoring must remain operational during incidents.

---

## MTTR Is A Reliability Metric

Availability alone is insufficient.

Recovery speed is equally important.

---

## Reliability Governance Still Applies

Even during chaos experiments:

- SLOs remain valid
- Alert routing remains valid
- Release gates remain valid

---

# Part 9 — Cost-Control Cleanup

Delete:

```bash
kubectl delete job cpu-stress \
  -n reliability-lab \
  --ignore-not-found
```

Remove ingress resources.

Remove monitoring.

Remove application.

Destroy infrastructure:

```bash
terraform destroy
```

---

## AWS Load Balancer Controller Cleanup

Attempt Helm removal:

```bash
helm uninstall aws-load-balancer-controller \
  -n kube-system || true
```

Possible result:

```txt
release not found
```

This indicates:

- controller already removed
- Helm state missing
- controller installed outside current Helm state

Verify directly:

```bash
helm list -A | grep load-balancer || true

kubectl get deployment aws-load-balancer-controller \
  -n kube-system \
  --ignore-not-found

kubectl get pods -n kube-system \
  | grep load-balancer || true
```

If resources remain:

```bash
kubectl delete deployment aws-load-balancer-controller \
  -n kube-system \
  --ignore-not-found

kubectl delete serviceaccount aws-load-balancer-controller \
  -n kube-system \
  --ignore-not-found
```

---

## Operational Lesson

Cleanup should be validated at:

- Helm layer
- Kubernetes layer
- AWS layer

Never assume tooling state is authoritative.

Trust operational evidence.

---

# Evidence Inventory

```txt
experiments/evidence/advanced-chaos/
```

Contains:

- Terraform evidence
- Cluster evidence
- Monitoring evidence
- Latency tests
- Outage tests
- Resource exhaustion tests
- Alert routing validation
- MTTR measurements
- Reliability scorecards

---

# Outcome

This phase demonstrated:

- Controlled failure injection
- Resilience validation
- MTTR measurement
- Alert routing verification
- Reliability governance under failure
- Operational recovery procedures
- Cost-controlled infrastructure teardown

The platform can now be evaluated not only for reliability during normal operation, but also for resilience during controlled failure conditions.

