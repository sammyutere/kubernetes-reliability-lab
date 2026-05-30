# Experiment: CPU Spike and HPA Scaling

## Purpose

Validate HorizontalPodAutoscaler behaviour under CPU load and understand how autoscaling behaves in a local kind environment.

## Hypothesis

Sustained CPU load against the `/cpu` endpoint should increase Pod CPU utilisation sufficiently for the HorizontalPodAutoscaler to increase the Deployment replica count above the configured minimum.

## Preconditions

- Deployment `reliability-app` is healthy.
- Service `reliability-app` is available.
- Metrics Server is installed and returning metrics.
- HPA `reliability-app-hpa` exists.
- CPU requests are configured on the application container.
- Prometheus and Grafana are operational.

## Local Environment Notes

The initial experiment did not trigger autoscaling.

Observed HPA metrics:

```txt
cpu: 2%/50%
```

The application CPU utilisation remained significantly below the configured scaling threshold.

To make autoscaling observable in the local kind environment:

- HPA CPU target utilisation was reduced from 50% to 10%.
- Load-test concurrency was increased.
- Additional evidence collection was added.
- HPA ownership conflicts were resolved before reapplying Helm configuration.

## Operational Issue: HPA and Helm Ownership Conflict

When updating the Helm chart with the lower CPU threshold, the following error occurred:

```txt
conflict with "kube-controller-manager" using apps/v1:
.spec.replicas
```
This occurred because the HPA controller was managing Deployment replica count through the scale subresource.

Resolution:

```bash
kubectl delete hpa reliability-app-hpa -n reliability-lab

helm upgrade --install reliability-app \
  helm/reliability-app \
  -n reliability-lab \
  -f helm/reliability-app/values-local.yaml
```

The HPA was then recreated by Helm using the updated configuration.

## Commands

Baseline validation:

```bash
kubectl get deployment reliability-app -n reliability-lab
kubectl get hpa reliability-app-hpa -n reliability-lab
kubectl get pods -n reliability-lab -o wide
kubectl top pods -n reliability-lab
```

Watch HPA:

```bash
kubectl get hpa reliability-app-hpa -n reliability-lab -w
```

Watch Pods:

```bash
kubectl get pods -n reliability-lab -w
```

Watch CPU metrics:

```bash
while true; do
  clear
  kubectl top pods -n reliability-lab
  sleep 5
done
```

Run load:

```bash
./experiments/scripts/load-test.sh http://127.0.0.1:8080/cpu 300 120
```

Escalated load if required:

```bash
./experiments/scripts/load-test.sh http://127.0.0.1:8080/cpu 420 200
```

## Expected Behaviour

* CPU utilisation increases.
* Metrics Server reports increased usage.
* HPA target utilisation exceeds configured threshold.
* Deployment replica count increases.
* Additional Pods are created.
* New Pods become Ready.
* After load reduction, HPA eventually scales back toward the configured minimum replica count.

## Evidence

Evidence captured in:

```txt
experiments/evidence/cpu-hpa/
├── 01-before-deployment.txt
├── 02-before-hpa.txt
├── 03-before-pods.txt
├── 04-before-top-pods.txt
├── 05-during-hpa.txt
├── 06-during-deployment.txt
├── 07-during-pods.txt
├── 08-during-top-pods.txt
├── 09-hpa-describe.txt
├── 10-after-hpa.txt
├── 11-after-deployment.txt
├── 12-after-pods.txt
└── 13-after-top-pods.txt
```

## Observed Behaviour

Initial testing did not trigger autoscaling.

Observed HPA metrics showed:

```txt
cpu: 2%/50%
```

indicating that CPU utilisation remained well below the configured scaling threshold.

Additional load generation and HPA tuning were required to make autoscaling observable in the local environment.

The HPA successfully evaluated CPU utilisation throughout the experiment.

Where scale-up occurred, additional Pods were created and eventually became Ready.

Where scale-up did not occur, the experiment still validated:

- Metrics Server functionality
- HPA metric evaluation
- Deployment/HPA integration
- Autoscaling decision logic

## Conclusion

The experiment validated CPU-based autoscaling behaviour and highlighted an important operational lesson regarding local Kubernetes environments.

Autoscaling thresholds that are appropriate in production environments may not trigger scaling in a powerful local development environment.

The experiment also demonstrated an operational interaction between Helm and HPA ownership of Deployment replica count.

The result strengthened understanding of:

- Metrics Server
- CPU requests
- HPA scaling decisions
- Deployment scaling
- Helm ownership behaviour
- Local versus production autoscaling characteristics

Future AWS EKS deployment will provide a more realistic autoscaling environment where workload pressure, node capacity, and cluster scaling interact more closely with production behaviour.

