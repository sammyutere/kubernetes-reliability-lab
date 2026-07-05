# Phase 14 — Supply Chain Security and Deployment Trust

## Objective

Establish deployment trust by proving that container images are known, scanned, signed, verified, and documented before deployment.

This phase adds software supply chain security controls to the Kubernetes reliability project.

## Supply Chain Workflow

```txt
Build Image
↓
Generate SBOM
↓
Scan Image
↓
Push to Amazon ECR
↓
Sign Image
↓
Verify Signature
↓
Attest SBOM
↓
Document Provenance
↓
Run Deployment Trust Gate
```
## Tools Used

| Tool       | Purpose                               |
| ---------- | ------------------------------------- |
| Syft       | Generate SBOMs                        |
| Grype      | Scan images for vulnerabilities       |
| Cosign     | Sign images and verify signatures     |
| Amazon ECR | Store container images                |
| Sigstore   | Intended future keyless signing model |

## Images

| Service    | Image      |
| ---------- | ---------- |
| Frontend   | frontend   |
| API        | api        |
| Dependency | dependency |

## Controls Implemented

- SBOM generation
- Vulnerability scanning
- ECR image publishing
- Cosign image signing
- Cosign signature verification
- SBOM attestation
- Image provenance documentation
- Deployment trust gate

## Signing Approach

Keyless Sigstore signing was attempted first.

However, Fulcio certificate requests repeatedly timed out during the signing and attestation process.

To complete the lab reliably, the signing implementation was changed to local Cosign key-pair signing.

This still validates the core supply-chain security control:

```txt
Only signed and verified images should be trusted for deployment.
```
## Key-Pair Signing Workflow

A local Cosign key pair was generated:

```txt
supply-chain/keys/cosign.key
supply-chain/keys/cosign.pub
```
The private key is excluded from Git.

The public key is used to verify image signatures and SBOM attestations.

## Trust Decision

An image should be approved for deployment only when:

SBOM exists
Vulnerability scan report exists
Image has been pushed to ECR
Image signature verifies successfully
SBOM attestation verifies successfully
Provenance document exists
Deployment trust gate passes

## Deployment Trust Gate

The deployment trust gate validates:

```txt
Image signature
+
Vulnerability scan evidence
```
If either is missing, deployment should be blocked.

## Evidence

Evidence is stored in:

```txt
experiments/evidence/supply-chain-security/
```
Evidence includes:

- Tool versions
- ECR repository validation
- Local image validation
- SBOM files
- Vulnerability scan reports
- ECR image push evidence
- Cosign verification output
- SBOM attestation verification
-Image provenance
-Deployment trust gate output

## Operational Lessons

Keyless signing depends on external Sigstore services such as Fulcio.

If those services time out, key-pair signing can still prove the core lab objective:

```txt
Image integrity and authenticity can be verified before deployment.
```
For production CI/CD, keyless signing remains the preferred future approach because it avoids long-lived private signing keys.

## Outcome

This phase prepares the platform for stronger deployment trust controls.

The project now demonstrates:

- What is inside the image
- Whether the image contains known vulnerabilities
- Who signed or controlled the signing key
- Whether the image signature verifies
- Whether SBOM evidence exists
- Whether the image should be trusted for deployment
