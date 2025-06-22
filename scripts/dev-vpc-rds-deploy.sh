#!/bin/bash

# Usage: ./dev-deployment.sh dev|qa|prod

set -e

ENV=$1

if [[ -z "$ENV" ]]; then
  echo "Usage: $0 <environment: dev|qa|prod>"
  exit 1
fi

# Retrieve dynamic values
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region)

STACK_PREFIX="cru-wine"
TEMPLATE_DIR="../templates"
CONFIG_DIR="../configs/$ENV"

VPC_STACK_NAME="${STACK_PREFIX}-${ENV}-vpc"
DB_STACK_NAME="${STACK_PREFIX}-${ENV}-db"

# Define common tags
COMMON_TAGS="Environment=${ENV} AccountId=${ACCOUNT_ID} Region=${REGION} Owner=devops-team Project=cru-wine"

# Deploy VPC
echo "Deploying VPC stack: $VPC_STACK_NAME"
aws cloudformation deploy \
  --stack-name "$VPC_STACK_NAME" \
  --template-file "${TEMPLATE_DIR}/vpc.yaml" \
  --parameter-overrides file://"${CONFIG_DIR}/vpc-parameters.json" \
  --capabilities CAPABILITY_NAMED_IAM \
  --tags $COMMON_TAGS

# Wait until VPC stack is complete
echo "Waiting for VPC stack to complete..."
aws cloudformation wait stack-create-complete --stack-name "$VPC_STACK_NAME" 2>/dev/null || \
aws cloudformation wait stack-update-complete --stack-name "$VPC_STACK_NAME"

echo "VPC stack deployed successfully."

# Deploy DB
echo "Deploying DB stack: $DB_STACK_NAME"
aws cloudformation deploy \
  --stack-name "$DB_STACK_NAME" \
  --template-file "${TEMPLATE_DIR}/db.yaml" \
  --parameter-overrides file://"${CONFIG_DIR}/db-parameters.json" \
  --capabilities CAPABILITY_NAMED_IAM \
  --tags $COMMON_TAGS

echo "DB stack deployed successfully."
