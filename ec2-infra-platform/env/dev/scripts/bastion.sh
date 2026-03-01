#!/bin/bash
# set -euo pipefail

##############################################
# Variables
##############################################

REGION="ap-south-1"
LOG_FILE="/var/log/user-data.log"
SCHEMA_PATH="/tmp/schema.sql"

##############################################
# Logging setup
##############################################

exec > >(tee "$LOG_FILE" | logger -t user-data ) 2>&1

echo "Starting userdata..."

##############################################
# Install packages
##############################################

yum update -y
yum install -y amazon-cloudwatch-agent awscli jq tmux git tree telnet mariadb105 redis6

##############################################
# CloudWatch Agent Setup
##############################################

mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/

cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "$LOG_FILE",
            "log_group_name": "/ec2/userdata",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF

systemctl enable --now amazon-cloudwatch-agent

##############################################
# Redis
##############################################

systemctl enable redis6
systemctl start redis6

##############################################
# Wait for IAM role credentials
##############################################

echo "Waiting for IAM role credentials..."
until aws sts get-caller-identity --region "$REGION" >/dev/null 2>&1; do
  sleep 5
done

##############################################
# Download schema from S3
##############################################

echo "Downloading DB schema from S3..."
aws s3 cp s3://ullagalliu-artifacts/schema/schema.sql "$SCHEMA_PATH"

##############################################
# Validate schema file (EXISTS + NOT EMPTY)
##############################################

if [ ! -f "$SCHEMA_PATH" ]; then
  echo "ERROR: schema.sql file not found"
  exit 1
fi

if [ ! -s "$SCHEMA_PATH" ]; then
  echo "ERROR: schema.sql downloaded but file is empty"
  exit 1
fi

echo "Schema file exists and is valid"

##############################################
# Fetch RDS host from Parameter Store
##############################################

DB_HOST=$(aws ssm get-parameter \
  --name "/moneylag/rds/host" \
  --region "$REGION" \
  --query "Parameter.Value" \
  --output text)

echo "RDS host fetched from Parameter Store"

##############################################
# Fetch secrets from Secrets Manager
##############################################

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "3-tier/secrets" \
  --region "$REGION" \
  --query SecretString \
  --output text)

DB_USER=$(echo "$SECRET_JSON" | jq -r '.RDS_USER')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.RDS_PASS')

echo "RDS credentials fetched from Secrets Manager"

##############################################
# Validate secrets
##############################################

if [[ -z "$DB_USER" || -z "$DB_PASS" || "$DB_USER" == "null" || "$DB_PASS" == "null" ]]; then
  echo "ERROR: Missing RDS credentials"
  exit 1
fi

echo "RDS credentials validated"

##############################################
# Wait for MySQL to be reachable
##############################################

echo "Waiting for RDS to become reachable..."

RDS_READY=false
for i in {1..30}; do
  if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" >/dev/null 2>&1; then
    RDS_READY=true
    break
  fi
  sleep 5
done

if [ "$RDS_READY" = false ]; then
  echo "ERROR: RDS not reachable after retries"
  exit 1
fi

echo "RDS is reachable"

##############################################
# Apply schema
##############################################

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" < "$SCHEMA_PATH"

echo "MySQL schema applied successfully"

##############################################
# Fetch private key from Parameter Store
##############################################

aws ssm get-parameter \
  --name "/ssh/siva" \
  --with-decryption \
  --region "$REGION" \
  --query "Parameter.Value" \
  --output text > /root/siva

chmod 400 /root/siva
chown root:root /root/siva

echo "Private key installed securely"

##############################################
# Done
##############################################

echo "Userdata completed successfully"
