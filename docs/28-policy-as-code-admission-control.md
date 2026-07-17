# Phase 15 — Policy-as-Code and Admission Control

## Objective

Introduce Kubernetes-native policy enforcement using Kyverno and connect
software supply-chain trust with workload governance.

This phase evaluates:

- Kyverno as an admission controller
- Required metadata enforcement
- CPU and memory governance
- Reproducible image-tag enforcement
- Signed-image admission enforcement
- Policy denial testing
- Pre-deployment trust controls

## Relationship to Previous Phases

Phase 14 established software supply-chain evidence:

```txt
Build
  ↓
SBOM
  ↓
Vulnerability Scan
  ↓
Cosign Signature
  ↓
Signature Verification
  ↓
Image Provenance
```
Phase 15 attempts to make those controls enforceable during Kubernetes admission:

```txt
Workload Submission
  ↓
Kubernetes API Server
  ↓
Kyverno Admission Controller
  ↓
Policy Evaluation
  ↓
Allow or Deny
```
## Environment Recovery

The AWS environment had been removed after the previous milestone for cost control.
Terraform infrastructure was rebuilt from:
terraform/environments/dev

The workflow included:
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan

The EKS kubeconfig was restored and the cluster nodes were validated before Kyverno installation.
Kyverno Installation
Kyverno was installed using Helm in the kyverno namespace.

The following controllers were validated:

- Admission controller
- Background controller
- Cleanup controller
- Reports controller

The admission-controller Service and endpoints were also checked before policy testing.
Stable Admission Policies
Required Standard Labels

Deployments in the reliability-lab namespace must include:

- app.kubernetes.io/name
- app.kubernetes.io/part-of

This improves ownership, inventory, observability, and operational governance.
Required Resource Requests and Limits

Containers must define:

- CPU request
- CPU limit
- Memory request
- Memory limit

This prevents unmanaged resource consumption and improves Kubernetes scheduling, autoscaling, and capacity planning.
Disallow the Latest Image Tag
Container images must not use the latest tag.

Fixed image tags improve:

- Reproducibility
- Traceability
- Rollback confidence
- Release governance

## Policy Denial Tests

The following negative tests were executed:

- Test
- Expected result
- Pod without resource requests and limits
- Denied
- Pod using nginx:latest
- Denied
- Deployment without standard labels
- Denied

The denied resources were confirmed absent from the cluster.
Evidence is stored in:

experiments/evidence/policy-as-code/
Signed-Image Enforcement Investigation
Signed-image admission enforcement was tested using private Amazon ECR images signed with a local Cosign key pair.

The investigation proved:

- ECR images were reachable.
- Kyverno could authenticate to private ECR.
- Cosign signature artefacts existed.
- The signatures verified using the approved public key.
- SBOM and vulnerability scan evidence existed.

## Legacy ClusterPolicy Result

The legacy verifyImages policy repeatedly returned:
no signatures found
This occurred even when Cosign could discover and verify the signature artefacts.

ImageValidatingPolicy Result
The newer ImageValidatingPolicy was also tested.
During evaluation, the Kyverno admission controller repeatedly panicked, causing the API server to report admission-webhook EOF failures.
The policy was removed to preserve admission-controller and Kubernetes API stability.
Safe Operational Workaround
Signed-image trust remains mandatory through a pre-deployment trust gate.

The gate verifies:
1 The Cosign signature using the approved public key.
2 The presence of a Grype vulnerability scan.
3 The presence of a Syft-generated SBOM.

A Helm deployment may proceed only when all referenced images pass the trust gate.
This creates the following workflow:

```txt
Build Image
  ↓
Generate SBOM
  ↓
Scan Image
  ↓
Sign Image
  ↓
Verify Signature
  ↓
Run Deployment Trust Gate
  ↓
Helm Deployment
  ↓
Kyverno Resource Governance
```
## Current Enforcement Position

Enforced by Kyverno

- Required standard labels
- CPU and memory requests and limits
- Prohibition of the latest image tag

Enforced Before Deployment

- Cosign signature verification
- SBOM presence
- Vulnerability scan presence

Deferred

Cluster-side signed-image verification is deferred until a stable and compatible Kyverno implementation has been validated.

## Operational Lessons

Admission Stability Takes Priority
A failing or crashing admission controller can disrupt all Kubernetes API write operations.
Unstable verification policies should therefore be removed rather than left in a fail-closed configuration that prevents legitimate cluster operations.
Cryptographic Validity and Admission Compatibility Are Separate
A signature may be cryptographically valid while an admission controller still cannot discover or interpret its registry representation.
Deployment trust depends on:

- Correct signing key
- Exact image digest
- Registry authentication
- Signature storage format
- Admission-controller compatibility
- Policy configuration

Tooling State Is Not the Only Evidence
The workflow validated actual:

- Pods
- Services
- Endpoints
- Policy denials
- Signature artefacts
- Verification output
- SBOMs
- Scan reports

Operational evidence is more authoritative than assumptions based solely on tool configuration.
Outcome
This milestone successfully implemented Kubernetes admission governance and policy testing.
It also completed an evidence-based signed-image enforcement investigation and introduced a safe pre-deployment trust-gate workaround.

The platform now applies policy controls at two layers:

Pre-deployment trust controls
+
Kubernetes admission governance

## Evidence

Evidence is stored in:
experiments/evidence/policy-as-code/

Key evidence includes:

- Kyverno final state
- Policy denial outputs
- Pre-deployment trust-gate results
- Trusted workload state
- Policy reports
- Cosign signature artefacts
- Supply-chain asset inventory
- Signed-image admission limitation record
