# Experiment: HorizontalPodAutoscaler Load Test

## Purpose

Validate that the reliability app scales horizontally when CPU demand increases.

## Hypothesis

When sustained CPU load is generated against the `/cpu` endpoint, the HorizontalPodAutoscaler should increase the number of reliability-app replicas above the minimum replica count.

## Preconditions

- Deployment `reliability-app` is running.
- Service `reliability-app` is available.
- Metrics Server is installed and returning metrics.
- HPA `reliability-app-hpa` exists.
- App has CPU requests configured.

## Commands

Verify Metrics Server:

```bash
kubectl top nodes
kubectl top pods -n reliability-lab
```
Apply HPA:

```bash
kubectl apply -f k8s/base/hpa.yaml
kubectl get hpa -n reliability-lab
```
Port-forward the Service:

```bash
kubectl port-forward svc/reliability-app 8080:80 -n reliability-lab
```
Watch HPA:

```bash
kubectl get hpa reliability-app-hpa -n reliability-lab -w
```
Watch Pods:

```bash
kubectl get pods -n reliability-lab -w
```
Run load:

```bash
./experiments/scripts/load-test.sh http://127.0.0.1:8080/cpu 180
```
## Expected Behaviour

- CPU utilisation rises.
- HPA increases replicas above 3.
- New Pods become Ready.
- After load stops, HPA eventually scales down toward 3.

## Evidence Capture

Record:

```bash
kubectl get hpa -n reliability-lab
kubectl describe hpa reliability-app-hpa -n reliability-lab
kubectl get deployment reliability-app -n reliability-lab
kubectl get pods -n reliability-lab -o wide
kubectl top pods -n reliability-lab
```
## Evidence

No screenshots were captured during this experiment execution.

Command-line evidence was observed during execution using:

```bash
kubectl get hpa reliability-app-hpa -n reliability-lab -w
kubectl get pods -n reliability-lab -w
kubectl top pods -n reliability-lab

Future experiments will include explicit evidence capture steps before, during, and after execution.

## Observed Behaviour

Initial Deployment replica count was 3 Pods.

Metrics Server required approximately 1–2 minutes after installation before `kubectl top` returned valid CPU metrics.

During sustained load generation against the `/cpu` endpoint, average CPU utilisation increased above the HPA target threshold of 50%.

The HorizontalPodAutoscaler increased the Deployment replica count from 3 replicas to 5 replicas.

New Pods transitioned through:

```txt
Pending → ContainerCreating → Running → Ready
```

The Kubernetes Service continued routing traffic successfully during scaling activity.

After load generation stopped, CPU utilisation gradually decreased. The HPA did not immediately scale down because the configured scale-down stabilization window delayed aggressive downscaling behaviour.

After several minutes, the Deployment scaled back toward the minimum replica count of 3.

No Pod failures or readiness probe failures were observed during the experiment.

## Conclusion

The experiment successfully validated CPU-based horizontal autoscaling for the reliability application.

The HorizontalPodAutoscaler correctly observed CPU utilisation metrics from Metrics Server and adjusted the Deployment replica count automatically in response to increased workload demand.

This demonstrated several important Kubernetes reliability capabilities:

- metric-driven autoscaling
- dynamic workload adaptation
- Deployment-driven replica management
- Service continuity during scaling events
- integration between Metrics Server and HPA

The experiment also demonstrated the importance of properly configured CPU resource requests, because HPA CPU utilisation calculations depend on declared resource requests.

Observed scale-down behaviour confirmed that Kubernetes intentionally delays rapid downscaling in order to reduce workload instability and replica thrashing.

In a production AWS EKS environment, this HPA behaviour would typically operate alongside node autoscaling systems such as Cluster Autoscaler or Karpenter.

## Follow-up Improvement

For future reliability experiments, evidence will be captured using screenshots and command outputs before, during, and after test execution.


