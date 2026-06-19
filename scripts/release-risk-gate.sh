#!/usr/bin/env bash
set -euo pipefail

ERROR_BUDGET_REMAINING="${1:-100}"
CANARY_HEALTH="${2:-pass}"

echo "Error budget remaining: ${ERROR_BUDGET_REMAINING}%"
echo "Canary health: ${CANARY_HEALTH}"

if [ "$ERROR_BUDGET_REMAINING" -lt 10 ]; then
  echo "BLOCKED: Error budget is below release threshold."
  exit 1
fi

if [ "$CANARY_HEALTH" != "pass" ]; then
  echo "BLOCKED: Canary health check failed."
  exit 1
fi

echo "APPROVED: Release can proceed."
