#!/usr/bin/env bash

set -euo pipefail

NAMESPACE="${1:-reliability-lab}"

echo "Selecting random reliability-app Pod..."

POD=$(kubectl get pods -n "${NAMESPACE}" \
  -l app.kubernetes.io/name=reliability-app \
  -o jsonpath='{.items[0].metadata.name}')

echo "Deleting Pod: ${POD}"

kubectl delete pod "${POD}" -n "${NAMESPACE}"

echo "Pod deleted."
