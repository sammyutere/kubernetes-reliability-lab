#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:?Usage: deployment-trust-gate.sh <image>}"

echo "Image: $IMAGE"
echo "Step 1: Verifying Cosign signature..."

cosign verify \
  --key supply-chain/keys/cosign.pub \
  "$IMAGE" >/tmp/cosign-verify-output.json

echo "Signature verified."

SERVICE=$(basename "$IMAGE" | cut -d: -f1)
TAG=$(basename "$IMAGE" | cut -d: -f2)
SCAN_FILE="supply-chain/scans/${SERVICE}-${TAG}-grype.json"

echo "Step 2: Checking scan evidence..."
echo "Expected scan file: $SCAN_FILE"

if [ ! -f "$SCAN_FILE" ]; then
  echo "BLOCKED: Vulnerability scan file missing."
  exit 1
fi

echo "Vulnerability scan found."
echo "APPROVED: Deployment trust gate passed."
