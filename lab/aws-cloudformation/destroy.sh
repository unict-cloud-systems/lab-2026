#!/usr/bin/env bash
set -e

STACK_NAME="lab-cloud-systems-2026"
REGION="us-east-1"

echo "Destroying stack: $STACK_NAME"

aws cloudformation delete-stack \
  --stack-name "$STACK_NAME" \
  --region "$REGION"

echo "Waiting for deletion..."
aws cloudformation wait stack-delete-complete \
  --stack-name "$STACK_NAME" \
  --region "$REGION"

echo "Stack deleted."
