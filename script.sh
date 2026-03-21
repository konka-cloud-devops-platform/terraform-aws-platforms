#!/bin/bash

set -e

ROOT_DIR=$(pwd)

echo "=============================="
echo " Terraform Project Selector"
echo "=============================="

# Get list of projects
PROJECTS=()
for dir in *-platform/; do
  PROJECTS+=("${dir%/}")
done

if [ ${#PROJECTS[@]} -eq 0 ]; then
  echo "❌ No Terraform projects found."
  exit 1
fi

echo "Available Projects:"
for i in "${!PROJECTS[@]}"; do
  echo "$((i+1)). ${PROJECTS[$i]}"
done

read -p "Select project number: " PROJECT_INDEX
PROJECT_INDEX=$((PROJECT_INDEX-1))

PROJECT_NAME=${PROJECTS[$PROJECT_INDEX]}

if [[ -z "$PROJECT_NAME" ]]; then
  echo "❌ Invalid project selection."
  exit 1
fi

PROJECT_PATH="$ROOT_DIR/$PROJECT_NAME"

echo "✔ Selected project: $PROJECT_NAME"

# Select environment
echo ""
echo "Select environment:"
echo "1. dev"
echo "2. prod"
read -p "Enter choice: " ENV_CHOICE

case $ENV_CHOICE in
  1) ENV="dev" ;;
  2) ENV="prod" ;;
  *) echo "❌ Invalid environment."; exit 1 ;;
esac

LIVE_PATH="$PROJECT_PATH/live"
ENV_TFVARS_PATH="$PROJECT_PATH/env/$ENV"

if [[ ! -d "$LIVE_PATH" ]]; then
  echo "❌ live directory not found!"
  exit 1
fi

if [[ ! -d "$ENV_TFVARS_PATH" ]]; then
  echo "❌ Environment directory not found!"
  exit 1
fi

# Select action
echo ""
echo "Select action:"
echo "1. Provision"
echo "2. Destroy"
read -p "Enter choice: " ACTION_CHOICE

cd "$LIVE_PATH"

# Terraform Init
echo ""
echo "▶ Terraform Init"
terraform init -upgrade -backend-config="$ENV_TFVARS_PATH/backend.tfvars"

if [ "$ACTION_CHOICE" == "1" ]; then

  echo ""
  echo "▶ Terraform Format"
  time terraform fmt

  echo ""
  echo "▶ Terraform Validate"
  time terraform validate

  echo "▶ Terraform Plan"
  time terraform plan -var-file="$ENV_TFVARS_PATH/main.tfvars"
  read -p "⚠️  Do you want to APPLY infrastructure? (yes/no): " CONFIRM

  if [[ "$CONFIRM" == "yes" ]]; then
    time terraform apply -var-file="$ENV_TFVARS_PATH/main.tfvars" -auto-approve
  else
    echo "❌ Apply cancelled."
  fi

elif [ "$ACTION_CHOICE" == "2" ]; then

  echo ""
  read -p "⚠️  Do you want to DESTROY infrastructure? (yes/no): " CONFIRM

  if [[ "$CONFIRM" == "yes" ]]; then
    time terraform destroy -var-file="$ENV_TFVARS_PATH/main.tfvars" -auto-approve
  else
    echo "❌ Destroy cancelled."
  fi

else
  echo "❌ Invalid action."
  exit 1
fi

echo ""
echo "✅ Done."
