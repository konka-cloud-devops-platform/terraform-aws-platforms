#!/bin/bash

set -e

ROOT_DIR=$(pwd)

echo "=============================="
echo " Terraform Project Selector"
echo "=============================="

# Get list of projects (folders containing 'live')
PROJECTS=()

for dir in *-platform/; do
  # remove trailing slash
  PROJECTS+=("${dir%/}")
done

if [ ${#PROJECTS[@]} -eq 0 ]; then
  echo "❌ No Terraform projects found."
  exit 1
fi

# Display projects
echo "Available Projects:"
for i in "${!PROJECTS[@]}"; do
  echo "$((i+1)). ${PROJECTS[$i]}"
done

# Select project
read -p "Select project number: " PROJECT_INDEX
PROJECT_INDEX=$((PROJECT_INDEX-1))

PROJECT_NAME=${PROJECTS[$PROJECT_INDEX]}
PROJECT_PATH="$ROOT_DIR/$PROJECT_NAME"

if [[ -z "$PROJECT_NAME" ]]; then
  echo "❌ Invalid project selection."
  exit 1
fi

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

ENV_PATH="$PROJECT_PATH/environments/$ENV"

# Select action
echo ""
echo "Select action:"
echo "1. Provision"
echo "2. Destroy"
read -p "Enter choice: " ACTION_CHOICE

cd "$ENV_PATH"

# Terraform Init
echo ""
echo "▶ Terraform Init"
terraform init

if [ "$ACTION_CHOICE" == "1" ]; then
  echo ""
  echo "▶ Terraform Format"
  time terraform fmt

  echo ""
  echo "▶ Terraform Validate"
  time terraform validate

  echo ""
  read -p "⚠️  Do you want to APPLY infrastructure? (yes/no): " CONFIRM
  if [[ "$CONFIRM" == "yes" ]]; then
    time terraform apply
  else
    echo "❌ Apply cancelled."
  fi

elif [ "$ACTION_CHOICE" == "2" ]; then
  echo ""
  read -p "⚠️  Do you want to DESTROY infrastructure? (yes/no): " CONFIRM
  if [[ "$CONFIRM" == "yes" ]]; then
    time terraform destroy
  else
    echo "❌ Destroy cancelled."
  fi

else
  echo "❌ Invalid action."
  exit 1
fi

echo ""
echo "✅ Done."
