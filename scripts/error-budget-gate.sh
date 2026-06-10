#!/usr/bin/env bash
set -euo pipefail

ERROR_BUDGET_REMAINING="${1:-100}"

echo "Error budget remaining: ${ERROR_BUDGET_REMAINING}%"

if [ "$ERROR_BUDGET_REMAINING" -lt 10 ]; then
  echo "ERROR: Error budget too low. Blocking release."
  exit 1
fi

echo "Error budget healthy. Release allowed."
