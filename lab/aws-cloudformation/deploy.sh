#!/usr/bin/env bash
set -e

STACK_NAME="lab-cloud-systems-2026"
TEMPLATE="stack.yaml"
REGION="us-east-1"

echo "Looking up latest Ubuntu 24.04 AMI in $REGION..."
UBUNTU_AMI=$(aws ec2 describe-images \
  --region "$REGION" \
  --owners 099720109477 \
  --filters \
    "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-*" \
    "Name=state,Values=available" \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
  --output text)
echo "Using AMI: $UBUNTU_AMI"

echo "Deploying stack: $STACK_NAME"

aws cloudformation deploy \
  --stack-name "$STACK_NAME" \
  --template-file "$TEMPLATE" \
  --region "$REGION" \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides UbuntuAMI="$UBUNTU_AMI"

echo ""
echo "=== Outputs ==="
aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --region "$REGION" \
  --query "Stacks[0].Outputs" \
  --output table
