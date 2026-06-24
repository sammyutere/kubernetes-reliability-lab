#!/usr/bin/env bash
set -euo pipefail

PROM_URL="${PROM_URL:-http://127.0.0.1:9090}"
MIN_SUCCESS_RATIO="${MIN_SUCCESS_RATIO:-0.999}"
MAX_ERROR_RATIO="${MAX_ERROR_RATIO:-0.001}"
MAX_LATENCY_SECONDS="${MAX_LATENCY_SECONDS:-0.5}"

query_prom() {
  local query="$1"
  curl -sG "${PROM_URL}/api/v1/query" \
    --data-urlencode "query=${query}" \
  | python3 -c 'import sys,json; d=json.load(sys.stdin); r=d["data"]["result"]; print(r[0]["value"][1] if r else "0")'
}

SUCCESS_RATIO=$(query_prom 'frontend:request_success_ratio:5m')
ERROR_RATIO=$(query_prom 'frontend:error_ratio:5m')
LATENCY=$(query_prom 'frontend:latency_p95_seconds:5m')

echo "Success ratio: ${SUCCESS_RATIO}"
echo "Error ratio: ${ERROR_RATIO}"
echo "p95 latency seconds: ${LATENCY}"

python3 - <<PY
success=float("${SUCCESS_RATIO}")
error=float("${ERROR_RATIO}")
latency=float("${LATENCY}")

min_success=float("${MIN_SUCCESS_RATIO}")
max_error=float("${MAX_ERROR_RATIO}")
max_latency=float("${MAX_LATENCY_SECONDS}")

if success < min_success:
    raise SystemExit("BLOCKED: Success ratio below SLO threshold")

if error > max_error:
    raise SystemExit("BLOCKED: Error ratio above SLO threshold")

if latency > max_latency:
    raise SystemExit("BLOCKED: Latency above SLO threshold")

print("APPROVED: SLO gate passed")
PY
