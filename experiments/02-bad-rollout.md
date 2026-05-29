# Experiment: Bad Rollout

## Purpose

Validate Kubernetes and Helm behaviour when a release introduces a broken container image.

## Hypothesis

If a Helm upgrade deploys an invalid image, the new Pods should fail to start, the rollout should not complete successfully, and the application should be recoverable using Helm rollback or a corrected Helm upgrade.

## Preconditions

- Helm release `reliability-app` exists.
- Deployment `reliability-app` is healthy.
- Service `reliability-app` exists.
- Current replica count is 3.

## Commands

Capture baseline:

```bash
kubectl get deployment reliability-app -n reliability-lab
kubectl get pods -n reliability-lab -o wide
helm history reliability-app -n reliability-lab
```
Trigger bad rollout:

```bash
helm upgrade reliability-app helm/reliability-app \
  -n reliability-lab \
  -f helm/reliability-app/values-local.yaml \
  --set image.repository=missing-image \
  --set image.tag=notfound
```
Observe failure:

```bash
kubectl rollout status deployment/reliability-app -n reliability-lab --timeout=90s
kubectl get pods -n reliability-lab -o wide
kubectl describe deployment reliability-app -n reliability-lab
kubectl get events -n reliability-lab --sort-by=.lastTimestamp
```
Recover:

```bash
helm history reliability-app -n reliability-lab
helm rollback reliability-app <previous-good-revision> -n reliability-lab
```
Alternative recovery:

```bash
helm upgrade --install reliability-app helm/reliability-app \
  -n reliability-lab \
  -f helm/reliability-app/values-local.yaml
```
## Expected Behaviour

- Helm upgrade creates a new release revision.
- Kubernetes attempts to create new Pods using the invalid image.
- New Pods fail with ErrImagePull or ImagePullBackOff.
- Rollout does not complete successfully.
- Existing healthy Pods may continue serving traffic during the failed rollout.
- Helm rollback or corrected upgrade restores the application.

## Evidence

Evidence captured in:

```txt
experiments/evidence/bad-rollout/
├── 01-before-deployment.txt
├── 02-before-pods.txt
├── 03-before-helm-history.txt
├── 04-failed-deployment.txt
├── 05-failed-pods.txt
├── 06-failed-deployment-describe.txt
├── 07-failed-events.txt
├── 08-failed-helm-history.txt
├── 09-healthz-during-failed-rollout.json
├── 10-after-recovery-deployment.txt
├── 11-after-recovery-pods.txt
├── 12-after-recovery-helm-history.txt
└── 13-after-recovery-events.txt
```
Additional evidence:

```txt
experiments/evidence/bad-rollout/14-helm-history-analysis.txt
```
## Observed Behaviour

The reliability-app Deployment was healthy before the experiment, with 3 desired replicas available.
A Helm upgrade was performed using an intentionally invalid image reference: missing-image:notfound.
Kubernetes attempted to create replacement Pods for the new rollout. The new Pods failed to start because the image could not be pulled, resulting in image pull failure states such as ErrImagePull or ImagePullBackOff.

The rollout did not complete successfully within the timeout period.
Existing healthy Pods remained available during the failed rollout, so the Service could still respond to health check traffic.
Helm release history was inspected before recovery.

The release history showed:

- Revision 1: initial successful installation
- Revisions 2–4: failed upgrades caused by Helm and kubectl field ownership conflicts
- Revisions 5–6: successful upgrades
- Revision 7: current active deployed release

Revision 7 was identified as the most recent known-good release and was selected as the rollback target for recovery validation.

An attempt was made to recover the application using:

```bash
helm rollback reliability-app 7 -n reliability-lab
```
However, the Deployment did not successfully recover and rollout monitoring returned:
error: deployment "reliability-app" exceeded its progress deadline
Because the rollback did not restore the application to a healthy state, an alternative recovery method was used.

The application was successfully restored using:

```bash
helm upgrade --install reliability-app \
  helm/reliability-app \
  -n reliability-lab \
  -f helm/reliability-app/values-local.yaml
```
After the Helm upgrade completed, the Deployment returned to the expected healthy state and all application Pods became available.
This demonstrated that multiple recovery strategies should be documented and tested rather than assuming a rollback will always succeed.

## Conclusion

## Conclusion

The experiment successfully validated failed rollout detection and recovery procedures.
A deliberately invalid container image caused the rollout to fail, producing image pull errors and preventing successful Deployment progression.
Kubernetes exposed the failure through Pod status, Deployment status, rollout timeout behaviour, and event messages.
An initial recovery attempt using Helm rollback did not successfully restore the Deployment. The rollout exceeded its progress deadline and remained unhealthy.
Recovery was ultimately achieved using a Helm upgrade with the known-good values configuration.
This outcome highlights an important operational lesson: recovery procedures should be tested rather than assumed. Multiple recovery paths should be documented, validated, and available to operators.
The experiment strengthened the reliability posture of the platform by validating failure detection, troubleshooting workflow, Helm history inspection, and alternative recovery procedures.

