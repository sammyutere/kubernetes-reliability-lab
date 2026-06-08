#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"

echo "AWS cleanup verification for region: ${AWS_REGION}"
echo

echo "EKS clusters:"
aws eks list-clusters --region "${AWS_REGION}" --output table || true
echo

echo "Load balancers:"
aws elbv2 describe-load-balancers \
  --region "${AWS_REGION}" \
  --query "LoadBalancers[].[LoadBalancerName,DNSName,State.Code,Type,Scheme]" \
  --output table || true
echo

echo "ECR repositories:"
aws ecr describe-repositories \
  --region "${AWS_REGION}" \
  --query "repositories[].[repositoryName,repositoryUri]" \
  --output table || true
echo

echo "CloudFormation stacks related to eksctl:"
aws cloudformation list-stacks \
  --region "${AWS_REGION}" \
  --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE CREATE_FAILED UPDATE_FAILED \
  --query "StackSummaries[].[StackName,StackStatus]" \
  --output table || true
