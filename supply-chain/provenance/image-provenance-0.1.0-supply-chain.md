# Image Provenance — 0.1.0-supply-chain

## Images

| Service | Image |
|---|---|
| Frontend | 393864004024.dkr.ecr.us-east-1.amazonaws.com/frontend:0.1.0-supply-chain |
| API | 393864004024.dkr.ecr.us-east-1.amazonaws.com/api:0.1.0-supply-chain |
| Dependency | 393864004024.dkr.ecr.us-east-1.amazonaws.com/dependency:0.1.0-supply-chain |

## Supply Chain Controls

- SBOM generation with Syft
- Vulnerability scanning with Grype
- Image publishing to Amazon ECR
- Image signing with Cosign local key pair
- Signature verification with Cosign public key
- SBOM attestation
- Deployment trust gate

## Operational Note

Keyless Sigstore signing was attempted but Fulcio timed out repeatedly. The lab used local Cosign key-pair signing to complete image signing, verification, and attestation reliably.
