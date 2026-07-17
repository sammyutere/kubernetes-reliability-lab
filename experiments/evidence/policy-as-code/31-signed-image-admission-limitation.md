# Signed-Image Admission Enforcement Limitation

Kyverno signed-image enforcement was tested using both the legacy
`ClusterPolicy.verifyImages` path and the newer `ImageValidatingPolicy`.

The following controls were independently proven:

- Images existed in private Amazon ECR repositories.
- Kyverno successfully authenticated to ECR.
- Cosign signature artifacts existed.
- Cosign verification succeeded using the approved public key.
- SBOM and vulnerability scan evidence existed.

The legacy image-verification policy repeatedly returned `no signatures found`
despite the signature artefacts being discoverable with Cosign.

The newer `ImageValidatingPolicy` caused repeated admission-controller panics
and admission-webhook `EOF` failures when evaluating locally keyed Cosign
signatures without transparency-log evidence.

To preserve Kubernetes API and admission-controller stability, both unstable
signed-image policies were removed.

Signed-image trust remained mandatory through a pre-deployment trust gate which
verifies:

1. The Cosign signature.
2. The vulnerability scan report.
3. The SBOM.

Kyverno continued to enforce stable admission controls for:

- Required Kubernetes labels.
- CPU and memory requests and limits.
- Prohibition of the `latest` image tag.

Cluster-side signed-image enforcement is deferred until a stable, compatible
Kyverno release is validated.
