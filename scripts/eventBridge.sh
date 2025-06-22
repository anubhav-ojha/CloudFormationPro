#!/bin/bash

# Usage: ./eventBridge.sh dev|qa|prod

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

EVENTBRIDGE_STACK_NAME="${STACK_PREFIX}-${ENV}-eventbridge"

# Define common tags
COMMON_TAGS="Environment=${ENV} AccountId=${ACCOUNT_ID} Region=${REGION} Owner=devops-team Project=cru-wine"

# Deploy EventBridge Scheduler stack
echo "Deploying EventBridge stack: $EVENTBRIDGE_STACK_NAME"
aws cloudformation deploy \
  --stack-name "$EVENTBRIDGE_STACK_NAME" \
  --template-file "${TEMPLATE_DIR}/eventbridge.yaml" \
  --parameter-overrides file://"${CONFIG_DIR}/eventbridge-parameters.json" \
  --capabilities CAPABILITY_NAMED_IAM \
  --tags $COMMON_TAGS

echo "EventBridge stack '$EVENTBRIDGE_STACK_NAME' deployed successfully."
