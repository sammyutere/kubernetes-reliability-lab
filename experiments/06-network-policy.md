# Experiment: NetworkPolicy Ingress Control

## Purpose

Validate Kubernetes NetworkPolicy behaviour for the reliability application.

## Hypothesis

When a NetworkPolicy selects the reliability-app Pods and allows ingress only from Pods labelled `access=allowed`, traffic from labelled client Pods should succeed and traffic from unlabelled client Pods should be denied.

## Preconditions

- Deployment `reliability-app` is running.
- Service `reliability-app` is available.
- NetworkPolicy `reliability-app-ingress-policy` exists.
- The cluster CNI supports NetworkPolicy enforcement.

## Commands

Apply NetworkPolicy:

```bash
kubectl apply -f k8s/base/networkpolicy.yaml
```
Verify policy:

```bash
kubectl get networkpolicy -n reliability-lab
kubectl describe networkpolicy reliability-app-ingress-policy -n reliability-lab
```
Allowed client test:

```bash
kubectl run curl-allowed-evidence \
  --image=curlimages/curl:8.10.1 \
  -n reliability-lab \
  --restart=Never \
  --labels="access=allowed" \
  --command -- sh -c \
  'curl -s -o /dev/null -w "%{http_code}\n" http://reliability-app/healthz'
```
Capture the result from the Pod logs, if the output file captures the creation message, instead of the HTTP result.

```bash
kubectl logs curl-allowed-evidence -n reliability-lab \
  > experiments/evidence/networkpolicy/04-allowed-pod-result.txt
```
Denied client test:

```bash
kubectl run curl-denied-evidence \
  --image=curlimages/curl:8.10.1 \
  -n reliability-lab \
  --restart=Never \
  --command -- sh -c \
  'curl --connect-timeout 5 -s -o /dev/null -w "%{http_code}\n" http://reliability-app/healthz || true'
```
Capture the result from the Pod logs, if the output file captures the creation message, instead of the HTTP result.

```bash
kubectl logs curl-denied-evidence -n reliability-lab \
  > experiments/evidence/networkpolicy/05-denied-pod-result.txt
```
## Expected Behaviour

If NetworkPolicy is enforced by the CNI:

- labelled client Pod returns HTTP 200
- unlabelled client Pod times out or returns HTTP code 000

If the CNI does not enforce NetworkPolicy:

- both labelled and unlabelled client Pods may return HTTP 200

## Evidence

Command output captured in:

```txt
experiments/evidence/networkpolicy/
├── 01-networkpolicy-list.txt
├── 02-networkpolicy-describe.txt
├── 03-pod-labels.txt
├── 04-allowed-pod-result.txt
└── 05-denied-pod-result.txt
```
## Observed Behaviour

The NetworkPolicy was created successfully and selected the reliability-app Pods.

The allowed client Pod with label `access=allowed` successfully reached the reliability-app Service and received HTTP 200.

The unlabelled client Pod was unable to reach the reliability-app Service and returned HTTP 000 or timed out.

This confirmed that the cluster CNI enforced the NetworkPolicy as expected.

## Conclusion

The experiment successfully validated ingress traffic control using Kubernetes NetworkPolicy.

The reliability-app Pods were isolated so that only explicitly permitted client Pods could connect to the application port.

This improves the project’s production-readiness by introducing network segmentation and least-privilege traffic control.

In a production EKS environment, this pattern would be used to restrict application ingress to trusted workloads such as ingress controllers, monitoring systems, or approved internal services.

## Additional Operational Observation

When migrating from manually-applied Kubernetes manifests to Helm-managed releases, existing resources caused Helm ownership conflicts because the resources were originally managed by `kubectl`.

The conflicting resources had to be deleted before Helm could successfully install and manage the release.
