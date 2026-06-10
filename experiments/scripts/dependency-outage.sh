#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-error}"

kubectl set env deployment/dependency \
  -n reliability-lab \
  FAILURE_MODE="${MODE}"

kubectl rollout status deployment/dependency \
  -n reliability-lab
