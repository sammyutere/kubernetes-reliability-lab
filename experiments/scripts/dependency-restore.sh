#!/usr/bin/env bash
set -euo pipefail

kubectl set env deployment/dependency \
  -n reliability-lab \
  FAILURE_MODE=none

kubectl rollout status deployment/dependency \
  -n reliability-lab
