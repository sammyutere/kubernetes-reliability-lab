#!/usr/bin/env bash
set -euo pipefail

PROM_URL="${PROM_URL:-http://127.0.0.1:9090}"

query_prom() {
  local query="$1"
  curl -sG "${PROM_URL}/api/v1/query" \
    --data-urlencode "query=${query}" \
  | python3 -c 'import sys,json; d=json.load(sys.stdin); r=d["data"]["result"]; print(r[0]["value"][1] if r else "0")'
}

SUCCESS_RATIO=$(query_prom 'frontend:request_success_ratio:5m')
ERROR_RATIO=$(query_prom 'frontend:error_ratio:5m')
LATENCY=$(query_prom 'frontend:latency_p95_seconds:5m')
UPSTREAM_FAILURES=$(query_prom 'frontend:upstream_failure_rate:5m')

cat <<REPORT
# Reliability Scorecard

| Metric | Value | Target |
|---|---:|---:|
| Success ratio | ${SUCCESS_RATIO} | >= 0.999 |
| Error ratio | ${ERROR_RATIO} | <= 0.001 |
| p95 latency seconds | ${LATENCY} | <= 0.5 |
| Upstream failure rate | ${UPSTREAM_FAILURES} | 0 |

## Release Decision

Use this scorecard before promoting production releases.
REPORT
