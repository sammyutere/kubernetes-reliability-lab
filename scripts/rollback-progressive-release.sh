#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-reliability-lab}"
INGRESS_FILE="${INGRESS_FILE:-k8s/progressive-delivery/frontend-weighted-ingress.yaml}"

echo "Rolling traffic back to stable..."

cat > "${INGRESS_FILE}" <<'YAML'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: frontend-progressive
  namespace: reliability-lab
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/healthcheck-path: /healthz
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}]'
    alb.ingress.kubernetes.io/actions.forward-weighted: >
      {"type":"forward","forwardConfig":{"targetGroups":[{"serviceName":"frontend","servicePort":"80","weight":100},{"serviceName":"frontend-canary","servicePort":"80","weight":0}]}}
spec:
  ingressClassName: alb
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: forward-weighted
                port:
                  name: use-annotation
YAML

kubectl apply -f "${INGRESS_FILE}"

echo "Rollback applied."
