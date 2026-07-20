#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:?Usage: deployment-trust-gate.sh <registry/repository:tag>}"
if [[ -n "${COSIGN_BIN:-}" ]]; then
  :
elif [[ -x "./tools/cosign-v2/cosign" ]]; then
  COSIGN_BIN="./tools/cosign-v2/cosign"
elif command -v cosign >/dev/null 2>&1; then
  COSIGN_BIN="$(command -v cosign)"
else
  echo "BLOCKED: Cosign was not found in ./tools/cosign-v2 or PATH"
  exit 1
fi
PUBLIC_KEY="${PUBLIC_KEY:-supply-chain/keys/cosign.pub}"

if [[ ! -x "$COSIGN_BIN" ]]; then
  echo "BLOCKED: Cosign binary not found: $COSIGN_BIN"
  exit 1
fi

if [[ ! -f "$PUBLIC_KEY" ]]; then
  echo "BLOCKED: Cosign public key not found: $PUBLIC_KEY"
  exit 1
fi

echo "Image: $IMAGE"
echo "Step 1: Verify cryptographic signature"

"$COSIGN_BIN" verify \
  --key "$PUBLIC_KEY" \
  --insecure-ignore-tlog=true \
  "$IMAGE" \
  >/tmp/deployment-trust-cosign.json

echo "PASS: Signature verified"

IMAGE_PATH="${IMAGE##*/}"
SERVICE="${IMAGE_PATH%%:*}"
TAG="${IMAGE_PATH##*:}"

SCAN_FILE="supply-chain/scans/${SERVICE}-${TAG}-grype.json"
SBOM_FILE="supply-chain/sbom/${SERVICE}-${TAG}.cyclonedx.json"

echo "Step 2: Validate vulnerability scan evidence"

if [[ ! -s "$SCAN_FILE" ]]; then
  echo "BLOCKED: Missing or empty scan report: $SCAN_FILE"
  exit 1
fi

echo "PASS: Vulnerability scan evidence found"

echo "Step 3: Validate SBOM evidence"

if [[ ! -s "$SBOM_FILE" ]]; then
  echo "BLOCKED: Missing or empty SBOM: $SBOM_FILE"
  exit 1
fi

echo "PASS: SBOM evidence found"
echo "APPROVED: Deployment trust gate passed for $IMAGE"
