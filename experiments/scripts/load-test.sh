#!/usr/bin/env bash
set -euo pipefail

URL="${1:-http://127.0.0.1:8080/cpu}"
DURATION_SECONDS="${2:-300}"
CONCURRENCY="${3:-80}"

echo "Starting load test"
echo "URL: ${URL}"
echo "Duration: ${DURATION_SECONDS}s"
echo "Concurrency: ${CONCURRENCY}"

end_time=$((SECONDS + DURATION_SECONDS))

while [ "$SECONDS" -lt "$end_time" ]; do
  for i in $(seq 1 "$CONCURRENCY"); do
    curl -s "${URL}" > /dev/null &
  done
  wait
done

echo "Load test complete"
