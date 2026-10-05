# Postmortem — Trusted Release Rollout Blocked by Pod-Density Exhaustion

## Executive Summary

A GitOps promotion of the trusted `0.1.0-supply-chain` release caused all three application Deployments to exceed their Kubernetes progress deadlines.

The images and manifests were valid. The new Pods could not be scheduled because all three EKS worker nodes had reached their Pod-density limit.

Terraform increased the managed node group from three to four workers. The fourth node became Ready, the Pending Pods scheduled automatically, and Argo CD returned to Synced and Healthy without bypassing GitOps.

## Impact

Existing application replicas remained available, but the deployment could not progress until additional cluster capacity became available.

There was no external customer impact because this was a lab environment.

## Timeline

1. Trusted images passed Cosign, Grype and SBOM verification.
2. Helm desired state changed to `0.1.0-supply-chain`.
3. The change reached Git.
4. Argo CD detected and applied the new desired state.
5. frontend, api and dependency each created a surge Pod.
6. All three surge Pods remained Pending.
7. Deployments exceeded their progress deadlines.
8. Scheduler events reported `Too many pods`.
9. Terraform node-group desired/max capacity changed from 3 to 4.
10. A fourth worker became Ready.
11. Pending Pods scheduled.
12. Remaining rollout replicas completed automatically.
13. Argo CD returned to Synced and Healthy.

## Root Cause

The cluster had exhausted its allocatable Pod slots.

The failure was caused by Pod-density exhaustion rather than CPU, memory, image availability or application health.

## Contributing Factors

- Three-node development cluster
- Multiple platform controllers
- Prometheus monitoring stack
- Kyverno controllers
- Argo CD control-plane workloads
- Two replicas per application service
- Simultaneous rolling updates
- Lack of automated node scaling
- Insufficient deployment surge headroom

## What Went Well

- Existing application replicas remained healthy.
- Git remained the source of application desired state.
- Supply-chain verification had already succeeded.
- Scheduler events identified the capacity problem precisely.
- Infrastructure capacity was corrected through Terraform.
- Kubernetes recovered automatically once capacity existed.
- No imperative application mutation was required.

## What Could Be Improved

- Measure Pod-density capacity before release.
- Include deployment surge in capacity planning.
- Alert on allocatable-versus-scheduled Pod slots.
- Avoid relying solely on static worker counts in production.

## Corrective Actions

### Completed

- Increased Terraform-managed node-group maximum and desired size to four.
- Verified all four nodes Ready.
- Verified six application Pods Running.
- Verified trusted images live.
- Verified Argo CD Synced and Healthy.
- Captured failure and recovery evidence.

### Production Improvements

- Karpenter or Cluster Autoscaler
- Pod-slot monitoring
- Deployment headroom targets
- Pod priority classes
- Scheduling alerts
- Pre-deployment capacity checks

## Key Reliability Lesson

A Kubernetes platform can have adequate CPU and memory while still being unable to schedule another Pod.

Pod-density limits are a first-class capacity constraint.
