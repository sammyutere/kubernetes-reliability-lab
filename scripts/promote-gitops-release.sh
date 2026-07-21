#!/usr/bin/env bash
set -euo pipefail

TAG="${1:?Usage: promote-gitops-release.sh <image-tag>}"
VALUES_FILE="${VALUES_FILE:-helm/multi-service-app/values-eks.yaml}"
AWS_REGION="${AWS_REGION:-us-east-1}"

for command in aws docker git yq; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "BLOCKED: Required command not found: $command"
    exit 1
  fi
done

if [[ ! -f "$VALUES_FILE" ]]; then
  echo "BLOCKED: Helm values file not found: $VALUES_FILE"
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "BLOCKED: The Git working tree must be clean before promotion."
  git status --short
  exit 1
fi

BRANCH="$(git branch --show-current)"

if [[ "$BRANCH" != "main" ]]; then
  echo "BLOCKED: Release promotion must be performed from main."
  echo "Current branch: $BRANCH"
  exit 1
fi

echo "Validating AWS authentication..."

AWS_ACCOUNT_ID="$(
  aws sts get-caller-identity \
    --query Account \
    --output text
)"

if [[ -z "$AWS_ACCOUNT_ID" || "$AWS_ACCOUNT_ID" == "None" ]]; then
  echo "BLOCKED: Unable to determine the AWS account."
  exit 1
fi

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

FRONTEND_IMAGE="${ECR_REGISTRY}/frontend:${TAG}"
API_IMAGE="${ECR_REGISTRY}/api:${TAG}"
DEPENDENCY_IMAGE="${ECR_REGISTRY}/dependency:${TAG}"

echo
echo "Release candidate:"
echo "  Frontend:   $FRONTEND_IMAGE"
echo "  API:        $API_IMAGE"
echo "  Dependency: $DEPENDENCY_IMAGE"

echo
echo "Refreshing Amazon ECR authentication..."

aws ecr get-login-password \
  --region "$AWS_REGION" \
  | docker login \
      --username AWS \
      --password-stdin "$ECR_REGISTRY" \
      >/dev/null

echo "PASS: Amazon ECR authentication refreshed."

echo
echo "Running mandatory deployment trust gates..."

./scripts/deployment-trust-gate.sh "$FRONTEND_IMAGE"
./scripts/deployment-trust-gate.sh "$API_IMAGE"
./scripts/deployment-trust-gate.sh "$DEPENDENCY_IMAGE"

echo
echo "PASS: All images passed the deployment trust gate."
echo "Updating GitOps desired state..."

yq -i \
  ".frontend.image.repository = \"${ECR_REGISTRY}/frontend\" |
   .frontend.image.tag = \"${TAG}\" |
   .api.image.repository = \"${ECR_REGISTRY}/api\" |
   .api.image.tag = \"${TAG}\" |
   .dependency.image.repository = \"${ECR_REGISTRY}/dependency\" |
   .dependency.image.tag = \"${TAG}\"" \
  "$VALUES_FILE"

echo
echo "Promotion diff:"
git diff -- "$VALUES_FILE"

echo
echo "PROMOTION PREPARED"
echo "Review the diff, commit it, and push it to trigger Argo CD."
