# Milestone 16 — GitOps and Platform Automation

## Objective

Implement a declarative, continuously reconciled and policy-governed delivery workflow for the Kubernetes Reliability Lab using:

- Git
- Helm
- Argo CD
- Kyverno
- Cosign
- Syft SBOM evidence
- Grype vulnerability-scan evidence
- Amazon ECR
- Amazon EKS
- Terraform

This milestone changes the application delivery model from direct cluster modification to Git-managed desired-state reconciliation.

---

## Relationship to the Wider Project

The Kubernetes Reliability Lab has progressively implemented the capabilities required to operate a production-style Kubernetes platform.

Earlier milestones established:

- Terraform-managed AWS infrastructure
- Amazon EKS
- Containerised application services
- Helm packaging
- Prometheus and Grafana monitoring
- Service-level objectives
- Reliability testing
- Chaos engineering
- Progressive delivery
- Software supply-chain security
- Cosign image signing
- SBOM generation
- Vulnerability scanning
- Kyverno policy-as-code
- Pre-deployment trust controls

This milestone connects those capabilities into a controlled delivery system.

The completed workflow is:

```text
Application Change
  ↓
Build Container Images
  ↓
Generate SBOMs
  ↓
Scan Images
  ↓
Sign Images
  ↓
Verify Deployment Trust Gate
  ↓
Update Git Desired State
  ↓
Review and Commit
  ↓
Push to Main
  ↓
Argo CD Reconciliation
  ↓
Kubernetes API Admission
  ↓
Kyverno Governance
  ↓
EKS Workload Deployment
  ↓
Argo CD Health Monitoring
```

The project now demonstrates not only how to deploy Kubernetes workloads, but how to operate a governed internal application-delivery platform.

---

# 1. Core GitOps Concepts

## 1.1 Desired State

Desired state is the configuration that should exist in the cluster.

For this project, desired state is stored in Git and includes:

- Helm templates
- EKS values
- Image repositories
- Image tags
- Replica counts
- Services
- Resource requests and limits
- Kubernetes labels
- Health probes
- ServiceMonitor resources
- Argo CD Applications
- Argo CD AppProjects
- Synchronisation configuration

Git is therefore the authoritative record of approved platform and application configuration.

## 1.2 Live State

Live state is the collection of Kubernetes resources currently present in the EKS cluster.

Examples include:

- Deployments
- Pods
- Services
- ConfigMaps
- ServiceMonitors
- Argo CD Applications
- Kyverno policies

## 1.3 Reconciliation

Reconciliation is the continuous process of:

1. Reading the desired state from Git.
2. Reading the live state from Kubernetes.
3. Comparing both states.
4. Identifying differences.
5. Applying the required correction.
6. Repeating the process continuously.

Argo CD performs this control loop.

```text
Observe Git
  ↓
Observe Kubernetes
  ↓
Compare Desired and Live State
  ↓
Apply Required Changes
  ↓
Repeat
```

## 1.4 Synchronisation Status

An Argo CD Application is:

- `Synced` when its live resources match the Git-rendered target state.
- `OutOfSync` when one or more live resources differ from Git.

## 1.5 Health Status

Health status describes the operational condition of the application.

Examples include:

- `Healthy`
- `Progressing`
- `Degraded`
- `Missing`
- `Unknown`

Sync and health answer different questions.

```text
Sync status:
Does the cluster match Git?

Health status:
Are the running resources operating correctly?
```

An application may therefore be:

- Synced and Healthy
- Synced and Degraded
- OutOfSync and Healthy
- OutOfSync and Degraded

---

# 2. Environment Recovery

The previous milestone ended with AWS cost-control cleanup. The EKS environment therefore had to be recreated before GitOps implementation could begin.

Terraform was executed from:

```text
terraform/environments/dev
```

The recovery workflow was:

```bash
terraform init -upgrade
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show -no-color tfplan
terraform apply tfplan
```

The binary `tfplan` remained excluded from Git.

The EKS kubeconfig was restored with:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name reliability-lab-dev
```

An important Terraform distinction was identified during recovery.

The command:

```bash
terraform output -raw reliability-lab-dev
```

was incorrect because `reliability-lab-dev` was the value of the cluster name, not the name of a Terraform output.

The correct alternatives were:

```bash
terraform output -raw cluster_name
```

or:

```bash
export EKS_CLUSTER_NAME="reliability-lab-dev"
```

The recovered environment was validated using:

- AWS identity
- Kubernetes context
- Kubernetes API connectivity
- EKS node readiness
- Namespace availability
- Terraform outputs

---

# 3. Monitoring Platform Recovery

The first server-side validation of the multi-service Helm chart returned:

```text
no matches for kind "ServiceMonitor"
in version "monitoring.coreos.com/v1"
```

The following built-in resources validated successfully:

- API Service
- Dependency Service
- Frontend Service
- API Deployment
- Dependency Deployment
- Frontend Deployment

Only the three `ServiceMonitor` resources failed.

This proved that:

- The Helm chart rendered successfully.
- The Kubernetes API accepted the built-in resources.
- Kyverno permitted the application workloads.
- The recovered cluster was missing the Prometheus Operator CRDs.

A `ServiceMonitor` is not a built-in Kubernetes resource. It requires the Prometheus Operator CRDs.

The `kube-prometheus-stack` was restored before Argo CD deployment.

The restored monitoring platform included:

- Prometheus Operator
- Prometheus
- Alertmanager
- Grafana
- kube-state-metrics
- node-exporter
- ServiceMonitor CRD
- PodMonitor CRD
- PrometheusRule CRD
- Related monitoring resources

Prometheus was configured to discover ServiceMonitors across namespaces:

```yaml
prometheus:
  prometheusSpec:
    serviceMonitorSelector: {}
    serviceMonitorSelectorNilUsesHelmValues: false
    serviceMonitorNamespaceSelector: {}

    podMonitorSelector: {}
    podMonitorSelectorNilUsesHelmValues: false
    podMonitorNamespaceSelector: {}
```

After the monitoring platform was restored, all Services, Deployments and ServiceMonitors passed server-side dry-run validation.

The application was not manually installed after validation. Its first real installation remained the responsibility of Argo CD.

---

# 4. Kyverno Governance Recovery

Kyverno was reinstalled in its dedicated namespace.

The stable policies from the previous milestone were restored:

- Required standard labels
- Required CPU and memory requests and limits
- Prohibition of the `latest` image tag

The unstable signed-image admission policies were not restored because the previous milestone demonstrated an admission-controller compatibility problem.

Signed-image trust continued to be enforced through the pre-deployment trust gate.

The division of responsibility is:

```text
Argo CD:
What should exist?

Kyverno:
Is the submitted Kubernetes resource permitted?

Trust gate:
Is the release artefact approved for promotion?
```

---

# 5. Argo CD Installation

Argo CD was installed into:

```text
argocd
```

using a pinned release manifest.

The installation provided:

- Application controller
- ApplicationSet controller
- Argo CD API server
- Repository server
- Redis
- Dex
- Notifications controller
- Application CRD
- ApplicationSet CRD
- AppProject CRD

## 5.1 Initial Scheduling Failure

The first installation state included:

```text
argocd-application-controller-0   Pending
argocd-server                     Pending
argocd-dex-server                 CrashLoopBackOff
```

The Services and CRDs existed, but the platform was not accepted as healthy.

The Pending application-controller and server Pods had:

```text
NODE: <none>
IP:   <none>
```

Cluster-capacity investigation showed that the recovered environment was now running:

- EKS system components
- kube-prometheus-stack
- Prometheus
- Grafana
- Alertmanager
- Prometheus Operator
- Kyverno
- Argo CD

The original EKS worker capacity was insufficient for the combined platform workload.

The development EKS managed-node-group configuration was increased from two desired nodes to three:

```hcl
min_size     = 2
max_size     = 3
desired_size = 3

instance_types = ["t3.medium"]
```

Terraform was used to apply the capacity change.

After the additional worker joined the cluster:

- `argocd-application-controller` became Running.
- `argocd-server` became Running.
- The previously Pending Pods received node assignments and Pod IPs.

Dex was diagnosed independently and the Argo CD installation was not considered complete until every component was stable and Ready.

The final accepted state required all Argo CD Pods to show:

```text
READY:  1/1
STATUS: Running
```

with no continuously increasing restart count.

---

# 6. Argo CD Access and Authentication

Argo CD was accessed using local port forwarding rather than a public AWS load balancer:

```bash
kubectl port-forward \
  service/argocd-server \
  -n argocd \
  8080:443
```

The initial administrator password was obtained from:

```text
argocd-initial-admin-secret
```

On macOS, it was copied directly to the clipboard:

```bash
kubectl get secret argocd-initial-admin-secret \
  -n argocd \
  -o jsonpath='{.data.password}' \
  | base64 --decode \
  | pbcopy
```

The password and Argo CD session tokens were not stored in:

- Git
- Evidence files
- Documentation
- Shell scripts
- Kubernetes manifests

During later testing, the Argo CD CLI session token expired and returned:

```text
invalid session: token is expired
```

This was resolved by re-authenticating through the local port-forwarded Argo CD endpoint.

The cluster and Applications did not require recreation.

---

# 7. Annotation-Based Resource Tracking

Argo CD normally uses the following label for resource tracking:

```text
app.kubernetes.io/instance
```

Helm, Kyverno and other platform tools may also use that label.

To avoid resource-ownership conflicts, Argo CD was configured to use annotation-based tracking:

```text
application.resourceTrackingMethod: annotation
```

The resulting workload resources received Argo CD tracking annotations.

This provided a clearer separation between:

- Application labels
- Helm labels
- Kyverno policy labels
- Argo CD ownership metadata

---

# 8. Argo CD AppProject

An AppProject named:

```text
reliability-platform
```

was created.

The project restricts:

- Approved Git repositories
- Permitted cluster destinations
- Permitted namespaces
- Permitted resource types

The project allowed the Kubernetes Reliability Lab repository as a source and the `reliability-lab` namespace as a destination.

The AppProject provides a platform-governance boundary around the application.

---

# 9. Declarative Argo CD Application

The `multi-service-app` Application was defined in Git.

It specified:

```text
Repository:
https://github.com/sammyutere/kubernetes-reliability-lab.git

Revision:
main

Path:
helm/multi-service-app

Values:
values-eks.yaml

Release:
multi-service-app

Destination:
https://kubernetes.default.svc

Namespace:
reliability-lab
```

Automated synchronisation was configured with:

```yaml
automated:
  enabled: true
  prune: true
  selfHeal: true
  allowEmpty: false
```

The following sync options were also enabled:

```yaml
- CreateNamespace=true
- PruneLast=true
- ApplyOutOfSyncOnly=true
```

Retry backoff was configured to handle transient reconciliation failures.

---

# 10. Root Bootstrap Application

A root Argo CD Application was introduced.

The root Application manages:

- The `reliability-platform` AppProject
- The `multi-service-app` child Application

The bootstrap relationship is:

```text
Root Bootstrap Application
  ↓
AppProject
  ↓
Child Application
  ↓
Helm Chart
  ↓
Kubernetes Resources
```

Only the root Application required an initial manual application:

```bash
kubectl apply \
  -f gitops/bootstrap/root-application.yaml
```

Kubernetes returned a warning about the Argo CD finalizer format, but the Application was created successfully.

The finalizer remained:

```text
resources-finalizer.argocd.argoproj.io
```

because it is the Argo CD-recognised cascading deletion finalizer.

The warning was non-fatal and did not prevent reconciliation.

---

# 11. Declarative Helm Management

Argo CD rendered the existing Helm chart directly from Git.

The Application status proved that:

- The Git repository was used.
- `main` was the tracked revision.
- `helm/multi-service-app` was the chart path.
- `values-eks.yaml` was used.
- The source type was Helm.
- Synchronisation was initiated automatically.
- All resources were successfully created.
- The Application reached `Synced`.
- The Application reached `Healthy`.

The reconciled resources included:

- Three Services
- Three Deployments
- Three ServiceMonitors

Argo CD also reported the three ECR application images.

This proved that normal application delivery no longer required:

```bash
helm upgrade
```

or:

```bash
kubectl apply
```

The supported delivery path became:

```text
Update Git
  ↓
Review Diff
  ↓
Commit
  ↓
Push
  ↓
Argo CD Reconciliation
```

---

# 12. Automated Reconciliation

Automated reconciliation was enabled.

When the Git revision changed, Argo CD:

1. Detected the updated repository revision.
2. Rendered the Helm chart.
3. Compared target manifests with the live cluster.
4. Applied missing or changed resources.
5. Assessed application health.
6. Updated sync and health status.

This established a continuously operating delivery control loop rather than a one-time deployment command.

---

# 13. Deterministic Drift Detection

The original replica drift test did not visibly show `OutOfSync`.

This did not necessarily mean drift detection failed.

With self-healing enabled, Argo CD could detect and correct the change before the status was manually observed.

A deterministic test was therefore used.

## 13.1 Self-Healing Temporarily Disabled Through Git

The child Application was managed by the root Application, so self-healing was not patched directly in the live cluster.

Instead, Git was updated:

```yaml
selfHeal: false
```

Automated Git synchronisation remained enabled.

This allowed a live-only modification to persist long enough to capture.

## 13.2 Managed Field Modified

An existing Git-managed label was changed directly in the live Deployment.

The changed label caused Argo CD to report:

```text
Sync Status: OutOfSync
Health Status: Healthy
```

The application remained Healthy because the workload continued operating, even though its configuration differed from Git.

## 13.3 Self-Healing Restored

Git was then updated to restore:

```yaml
selfHeal: true
```

Argo CD reconciled the Application and restored the Git-declared label value.

The Application returned to:

```text
Synced
Healthy
```

This provided separate evidence for:

- Drift detection
- `OutOfSync` status
- Self-healing
- Final recovery

---

# 14. Configuration Drift Correction

An initial configuration-drift test added an annotation that did not exist in the desired manifest.

The annotation was not removed automatically.

This was not used as the final evidence because Argo CD’s default client-side apply behaviour may not delete an arbitrary field introduced by another field manager when that field was never part of Argo CD’s desired configuration.

The final test used an existing Git-managed Service label:

```text
app.kubernetes.io/part-of
```

The frontend Service label was changed directly in the live cluster.

A continuous evidence watcher captured:

```text
Synced → OutOfSync → Synced
```

and:

```text
Git-managed value
  ↓
Manual drift value
  ↓
Git-managed value restored
```

Because the test modified an existing desired-state field, it demonstrated configuration drift correction more reliably than the arbitrary annotation test.

No destructive Argo CD options were introduced.

The following were deliberately avoided:

```yaml
Replace=true
Force=true
```

---

# 15. Automated Pruning

Automated pruning proves that Argo CD owns the full lifecycle of declared resources rather than only creating them.

A temporary ConfigMap was introduced:

```text
gitops-prune-test
```

## 15.1 Creation Validation

The first Kubernetes check returned:

```text
ConfigMap not found
```

This was not treated as pruning evidence because the ConfigMap had never been proven to exist.

The corrected workflow verified each delivery layer:

1. The template existed locally.
2. Helm rendered the ConfigMap.
3. The ConfigMap passed server-side admission dry run.
4. The file was committed.
5. The file existed on `origin/main`.
6. Argo CD rendered the ConfigMap.
7. Argo CD reconciled it.
8. The live ConfigMap had an Argo CD tracking annotation.

## 15.2 Server-Side Apply Warning

A full chart server-side dry run produced warnings similar to:

```text
failed to migrate kubectl.kubernetes.io/last-applied-configuration
conflict with "argocd-controller"
```

The validation still succeeded.

The warnings occurred because:

- Existing resources were managed by Argo CD.
- Argo CD used client-side apply.
- The local server-side dry run attempted to claim ownership of the client-side apply annotation.

The warnings were field-management conflicts, not schema failures or Kyverno denials.

The cleaner validation rendered only the temporary ConfigMap and used:

```bash
kubectl apply \
  --dry-run=server \
  --validate=strict
```

No `--force-conflicts` option was used.

Argo CD was not changed to Server-Side Apply merely to suppress the warning.

## 15.3 Pruning Test

After creation and ownership were proven, the ConfigMap template was removed from Git.

The removal was committed and pushed.

Argo CD detected that the previously managed ConfigMap was no longer part of desired state.

Because:

```yaml
prune: true
```

was enabled, Argo CD automatically deleted it.

The final sequence was:

```text
ConfigMap Declared in Git
  ↓
Argo CD Creates ConfigMap
  ↓
ConfigMap Tracking Confirmed
  ↓
ConfigMap Removed from Git
  ↓
Application Becomes OutOfSync
  ↓
Argo CD Prunes ConfigMap
  ↓
Application Returns to Synced
```

---

# 16. Git-Driven Configuration Delivery

A safe Helm value was changed through Git.

The workflow was:

1. Modify the Helm values file.
2. Run Helm lint.
3. Render the chart.
4. Run server-side admission dry run.
5. Review the Git diff.
6. Commit the change.
7. Push to `main`.
8. Allow Argo CD to reconcile it.
9. Confirm the live Deployment reflected the Git change.

The original value was later restored through another Git commit.

No direct Helm deployment command was used.

This proved that Git had become the supported application-control interface.

---

# 17. Corrected Kyverno Latest-Tag Policy

The first live `disallow-latest-image-tag` policy did not contain an enforce-mode Pod rule that reliably matched the test workload.

The policy was replaced in Git rather than modified only with `kubectl edit`.

The corrected policy:

- Matches Pods in `reliability-lab`.
- Uses rule-level `failureAction: Enforce`.
- Validates normal containers.
- Validates init containers.
- Validates ephemeral containers.
- Uses Kyverno autogen for higher-level Pod controllers.
- Rejects `:latest`.
- Allows fixed version tags and immutable digests.

The corrected policy covers:

- Pods
- Deployments
- StatefulSets
- DaemonSets
- Jobs
- CronJobs

The effective rule includes:

```yaml
match:
  any:
    - resources:
        kinds:
          - Pod
        namespaces:
          - reliability-lab

validate:
  failureAction: Enforce
```

and evaluates:

```text
request.object.spec.containers
request.object.spec.initContainers
request.object.spec.ephemeralContainers
```

The policy was validated with three controlled tests:

1. `nginx:latest` was denied.
2. A fixed `nginx` tag was allowed.
3. An init container using `busybox:latest` was denied.

This proved the policy was specific rather than blocking all workloads.

---

# 18. Kyverno Governance of Argo CD Deployments

The final GitOps governance test used a single-purpose invalid Pod.

The Pod had:

- Correct required labels
- CPU requests
- CPU limits
- Memory requests
- Memory limits
- `nginx:latest`

It violated only the corrected latest-tag policy.

## 18.1 Direct Admission Proof

Before involving Argo CD, the Helm-rendered Pod was submitted through a server-side dry run.

Kyverno denied it.

This isolated and proved the admission-control layer.

## 18.2 Deterministic Argo CD Test

Automatic synchronisation was temporarily disabled through Git:

```yaml
automated:
  enabled: false
```

This allowed the invalid resource to appear in Git without Argo CD immediately attempting and completing an operation before evidence capture.

The invalid Pod template was then:

1. Committed.
2. Pushed to `origin/main`.
3. Rendered by Argo CD.
4. Detected as missing from the live cluster.

The Application became:

```text
OutOfSync
Healthy
```

A deliberate Argo CD sync was then started.

The request flowed through:

```text
Git
  ↓
Argo CD
  ↓
Helm Rendering
  ↓
Kubernetes API
  ↓
Kyverno Admission Webhook
```

Kyverno rejected the Pod because it used:

```text
nginx:latest
```

The Argo CD operation failed and the Pod was never stored in Kubernetes.

This proved:

> Argo CD can automate reconciliation, but it cannot bypass Kyverno admission governance.

## 18.3 Recovery

The invalid Pod template was removed from Git.

Automated synchronisation was restored:

```yaml
enabled: true
prune: true
selfHeal: true
allowEmpty: false
```

The Application returned to:

```text
Synced
Healthy
```

The temporary invalid Pod was not retained in the final Helm chart.

---

# 19. Trust-Gated GitOps Promotion

Automated reconciliation creates an important release risk.

A newly pushed image tag in `values-eks.yaml` can automatically become a live deployment.

The promotion workflow therefore requires image trust verification before Git desired state is changed.

The gate verifies:

1. Cosign signature
2. Vulnerability-scan evidence
3. SBOM evidence

The promotion sequence is:

```text
Candidate Images
  ↓
Refresh ECR Authentication
  ↓
Verify Cosign Signatures
  ↓
Verify Vulnerability Scan Reports
  ↓
Verify SBOM Files
  ↓
Update Helm Values
  ↓
Review Git Diff
  ↓
Commit
  ↓
Push
  ↓
Argo CD Reconciliation
```

## 19.1 Expired ECR Authentication

The first GitOps trust-gate run failed with:

```text
DENIED: Your authorization token has expired
```

This was not a signature failure.

Amazon ECR credentials had expired and required renewal.

The corrected workflow validates the AWS session and obtains a fresh ECR login immediately before Cosign registry access:

```bash
aws sts get-caller-identity

aws ecr get-login-password \
  --region "$AWS_REGION" \
  | docker login \
      --username AWS \
      --password-stdin "$ECR_REGISTRY"
```

The promotion script was updated so every promotion refreshes ECR authentication before running the trust gate.

The evidence command also used:

```bash
set -o pipefail
```

so a trust-gate failure could not be concealed by output being piped through `tee`.

## 19.2 Transparency-Log Warning

Cosign returned:

```text
Skipping tlog verification is an insecure practice
```

This warning was expected under the current lab signing model.

The signatures were created with a local Cosign key and verified using the approved public key.

The current workflow uses:

```text
--insecure-ignore-tlog=true
```

because usable transparency-log evidence was not produced for those signatures.

This means:

- Cryptographic public-key verification is still performed.
- Registry image identity is still checked.
- The warning is not a signature verification failure.
- Transparency and public auditability are reduced.
- The workflow should not be represented as full production-grade Sigstore transparency verification.

A future production workflow should use:

- Keyless signing
- OIDC identity
- Rekor transparency-log inclusion
- Short-lived cloud credentials
- CI-based verification
- Protected branches
- Required status checks

---

# 20. Separation of Platform Responsibilities

## Terraform

Terraform manages AWS infrastructure:

- VPC
- Subnets
- NAT gateways
- EKS cluster
- Managed node groups
- IAM
- Security groups
- Supporting AWS resources

## Git

Git stores:

- Approved desired state
- Application history
- Policy definitions
- Reviewable changes
- Platform configuration

## Helm

Helm provides:

- Reusable application templates
- Environment-specific values
- Kubernetes resource generation

## Argo CD

Argo CD provides:

- Continuous reconciliation
- Git revision tracking
- Drift detection
- Self-healing
- Automated pruning
- Health assessment
- Deployment history

## Kyverno

Kyverno provides:

- Admission governance
- Required-label enforcement
- Resource-governance enforcement
- Immutable-tag enforcement
- Policy denial messages

## Trust Gate

The deployment trust gate provides:

- Cosign signature verification
- SBOM evidence validation
- Vulnerability-scan evidence validation
- Promotion blocking

## Kubernetes

Kubernetes provides:

- API admission
- Scheduling
- Deployment controllers
- Service discovery
- Runtime workload management

---

# 21. Operational Lessons

## 21.1 GitOps Requires a Remote Commit

Argo CD cannot read:

- Uncommitted local files
- Staged-only files
- Commits that have not been pushed
- Changes on an untracked branch when the Application tracks `main`

Every GitOps test therefore requires confirmation that the file exists on:

```text
origin/main
```

## 21.2 Refresh Is Not Synchronisation

The command:

```bash
argocd app get --hard-refresh
```

forces Argo CD to recalculate desired and live state.

It does not itself guarantee that resources will be applied.

Explicit synchronisation is performed with:

```bash
argocd app sync
```

when required.

## 21.3 Self-Healing Can Hide Transient OutOfSync States

With self-healing enabled, drift can be corrected before a human observes the `OutOfSync` state.

Deterministic evidence may require temporarily disabling self-healing through Git.

## 21.4 Newly Added Fields Are Poor Drift Tests

An arbitrary annotation absent from Git may not be removed reliably under client-side apply semantics.

Existing Git-managed fields provide stronger drift evidence.

## 21.5 Creation Must Be Proven Before Pruning

A missing resource is not evidence of pruning unless:

- It was first created.
- Argo CD ownership was confirmed.
- It was later removed from Git.
- Argo CD subsequently deleted it.

## 21.6 Admission Policies Must Be Tested Independently

Before testing Kyverno through Argo CD, the exact rendered resource should be submitted through a server-side admission dry run.

This isolates:

- Helm rendering
- Kubernetes schema
- Kyverno matching
- Enforce behaviour

## 21.7 Platform Capacity Is a Prerequisite

Adding monitoring, policy and GitOps controllers materially increases EKS workload requirements.

Platform Pods must not be accepted as healthy while:

- Pending
- CrashLooping
- Unschedulable
- Continuously restarting

Terraform remains the correct mechanism for durable capacity changes.

## 21.8 Registry Authentication Is Temporary

A previous successful Docker or Cosign operation does not guarantee that the cached ECR token remains valid.

Registry authentication must be refreshed as part of each promotion workflow.

---

# 22. Evidence

Evidence is stored under:

```text
experiments/evidence/gitops/
```

The evidence set includes:

- Milestone start state
- Local tool versions
- AWS identity
- Terraform validation
- Terraform plan
- Terraform outputs
- Recovered cluster state
- ECR image state
- Kyverno recovery
- Monitoring platform recovery
- Initial unhealthy Argo CD state
- Pending Pod scheduling events
- Cluster-capacity evidence
- Capacity-expansion Terraform plan
- Argo CD installation health
- Root bootstrap state
- Initial GitOps synchronisation
- Argo CD-rendered Helm manifests
- Application specification
- Workload tracking annotations
- Deterministic drift detection
- Self-healing evidence
- Configuration drift timeline
- Pruning resource creation
- Automated pruning timeline
- Git-driven configuration change
- Corrected latest-tag policy
- Direct Kyverno denial
- Argo CD failed operation caused by Kyverno
- GitOps recovery
- Successful release trust gate
- Blocked untrusted promotion
- Final platform state
- Pre-cleanup state
- Terraform destruction
- AWS cleanup verification

---

# 23. Milestone Outcome

The Kubernetes Reliability Lab now supports a declarative, continuously reconciled and policy-governed delivery model.

The final platform relationship is:

```text
Terraform
  ↓
Creates EKS Infrastructure

Git
  ↓
Defines Approved Desired State

Helm
  ↓
Renders Kubernetes Resources

Argo CD
  ↓
Reconciles Git and Kubernetes

Kyverno
  ↓
Enforces Admission Governance

Trust Gate
  ↓
Controls Release Promotion

Kubernetes
  ↓
Operates Approved Workloads
```

The completed milestone demonstrates:

- AWS/EKS environment recovery
- Monitoring prerequisite recovery
- Argo CD installation
- EKS capacity remediation
- Declarative Helm deployment
- App-of-apps bootstrap
- Automated synchronisation
- Drift detection
- Self-healing
- Configuration correction
- Automated pruning
- Git-driven delivery
- Corrected Kyverno enforcement
- Kyverno governance of Argo CD
- Trust-gated release promotion
- ECR authentication renewal
- Evidence-based troubleshooting
- Platform recovery through Git

The project has progressed from manual Kubernetes administration to an auditable GitOps delivery platform with independent release, reconciliation and governance controls.
