#!/bin/bash

##############################################
# OpenVPN Access Server - Complete Setup
# For Ubuntu-based OpenVPN AMI
##############################################

REGION="ap-south-1"
LOG_FILE="/var/log/openvpn-setup.log"

##############################################
# Logging setup
##############################################

exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo "OpenVPN Setup Started"
echo "Time: $(date)"
echo "=========================================="

##############################################
# Install packages (Ubuntu)
##############################################

echo "Step 1: Installing required packages..."

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y jq curl unzip wget

# Install AWS CLI v2
echo "Installing AWS CLI v2..."
cd /tmp
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip
cd -

echo "✓ Packages installed"

##############################################
# Install and Configure CloudWatch Agent
##############################################

echo ""
echo "Step 2: Installing CloudWatch Agent..."

# Download and install CloudWatch Agent for Ubuntu
cd /tmp
wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb
rm -f amazon-cloudwatch-agent.deb
cd -

echo "✓ CloudWatch Agent installed"

# Configure CloudWatch Agent
echo "Configuring CloudWatch Agent..."
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/

cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/openvpn-setup.log",
            "log_group_name": "/aws/ec2/openvpn",
            "log_stream_name": "{instance_id}/setup",
            "retention_in_days": 7,
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/openvpnas.log",
            "log_group_name": "/aws/ec2/openvpn",
            "log_stream_name": "{instance_id}/openvpnas",
            "retention_in_days": 30,
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "/aws/ec2/openvpn",
            "log_stream_name": "{instance_id}/syslog",
            "retention_in_days": 7,
            "timezone": "UTC"
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "OpenVPN/Server",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          {
            "name": "cpu_usage_idle",
            "rename": "CPU_IDLE",
            "unit": "Percent"
          },
          {
            "name": "cpu_usage_iowait",
            "rename": "CPU_IOWAIT",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60,
        "totalcpu": false
      },
      "disk": {
        "measurement": [
          {
            "name": "used_percent",
            "rename": "DISK_USED",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "mem": {
        "measurement": [
          {
            "name": "mem_used_percent",
            "rename": "MEM_USED",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60
      },
      "netstat": {
        "measurement": [
          {
            "name": "tcp_established",
            "rename": "TCP_ESTABLISHED",
            "unit": "Count"
          },
          {
            "name": "tcp_time_wait",
            "rename": "TCP_TIME_WAIT",
            "unit": "Count"
          }
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

# Start CloudWatch Agent
echo "Starting CloudWatch Agent..."
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Enable CloudWatch Agent to start on boot
systemctl enable amazon-cloudwatch-agent

echo "✓ CloudWatch Agent configured and started"

##############################################
# Fetch VPN Credentials from Secrets Manager
##############################################

echo ""
echo "Step 3: Fetching VPN credentials from Secrets Manager..."

SECRET_JSON=$(/usr/local/bin/aws secretsmanager get-secret-value \
  --secret-id "3-tier/secrets" \
  --region "$REGION" \
  --query SecretString \
  --output text 2>&1)

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to fetch secrets from Secrets Manager"
    echo "Error details: $SECRET_JSON"
    exit 1
fi

ADMIN_USER=$(echo "$SECRET_JSON" | jq -r '.VPN_ADMIN')
ADMIN_PASS=$(echo "$SECRET_JSON" | jq -r '.VPN_PASS')

if [ -z "$ADMIN_USER" ] || [ "$ADMIN_USER" == "null" ]; then
    echo "ERROR: VPN_ADMIN not found in secrets"
    exit 1
fi

if [ -z "$ADMIN_PASS" ] || [ "$ADMIN_PASS" == "null" ]; then
    echo "ERROR: VPN_PASS not found in secrets"
    exit 1
fi

echo "✓ VPN credentials fetched successfully"
echo "  Admin User: $ADMIN_USER"

##############################################
# Wait for OpenVPN to auto-initialize
##############################################

echo ""
echo "Step 4: Waiting for OpenVPN Access Server to auto-initialize..."

MAX_WAIT=300
WAIT_TIME=0

while ! systemctl is-active --quiet openvpnas && [ $WAIT_TIME -lt $MAX_WAIT ]; do
    echo "  Waiting for openvpnas service... ($WAIT_TIME seconds elapsed)"
    sleep 10
    WAIT_TIME=$((WAIT_TIME + 10))
done

if ! systemctl is-active --quiet openvpnas; then
    echo "Trying to start openvpnas service..."
    systemctl start openvpnas
    sleep 20
fi

echo "Waiting for OpenVPN configuration tools..."
sleep 30

if [ ! -f /usr/local/openvpn_as/scripts/sacli ]; then
    echo "ERROR: OpenVPN scripts not found"
    exit 1
fi

echo "✓ OpenVPN is ready"

##############################################
# Set Admin Password
##############################################

echo ""
echo "Step 5: Setting admin credentials..."

/usr/local/openvpn_as/scripts/sacli --user "$ADMIN_USER" --new_pass "$ADMIN_PASS" SetLocalPassword

if [ $? -eq 0 ]; then
    echo "✓ Admin password set successfully for user: $ADMIN_USER"
else
    echo "⚠ Warning: Failed to set password via sacli, trying ovpn-passwd..."
    echo "$ADMIN_PASS" | /usr/local/openvpn_as/scripts/ovpn-passwd -u "$ADMIN_USER" -p --stdin
fi

echo "✓ Admin credentials configured"

##############################################
# Configure OpenVPN Settings
##############################################

echo ""
echo "Step 6: Configuring OpenVPN advanced settings..."

VPC_CIDR="172.31.0.0/16"
VPN_CLIENT_SUBNET="10.8.0.0"

echo "  6a. Enabling IP forwarding..."
if ! grep -q "net.ipv4.ip_forward = 1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
fi
sysctl -p > /dev/null 2>&1
echo "  ✓ IP forwarding enabled"

echo "  6b. Configuring FULL tunnel..."
/usr/local/openvpn_as/scripts/sacli --key "vpn.client.routing.reroute_gw" --value "true" ConfigPut
echo "  ✓ Full tunnel enabled"

echo "  6c. Adding VPC network ($VPC_CIDR)..."
/usr/local/openvpn_as/scripts/sacli --key "vpn.server.routing.private_network.0" --value "$VPC_CIDR" ConfigPut
echo "  ✓ VPC route added"

echo "  6d. Enabling routing with NAT..."
/usr/local/openvpn_as/scripts/sacli --key "vpn.server.routing.enable" --value "true" ConfigPut
/usr/local/openvpn_as/scripts/sacli --key "vpn.server.routing.private_access" --value "nat" ConfigPut
echo "  ✓ NAT routing enabled"

echo "  6e. Enabling VPN gateway access..."
/usr/local/openvpn_as/scripts/sacli --key "vpn.server.routing.gateway_access" --value "true" ConfigPut
echo "  ✓ Gateway access enabled"

echo "  6f. Configuring DNS..."
/usr/local/openvpn_as/scripts/sacli --key "vpn.client.routing.reroute_dns" --value "true" ConfigPut
/usr/local/openvpn_as/scripts/sacli --key "vpn.server.dhcp.option.domain" --value "custom" ConfigPut
echo "  ✓ DNS configured"

echo "  6g. Enabling inter-client communication..."
/usr/local/openvpn_as/scripts/sacli --key "vpn.client.routing.inter_client" --value "true" ConfigPut
echo "  ✓ Inter-client communication enabled"

##############################################
# Configure NAT/Masquerading
##############################################

echo ""
echo "Step 7: Configuring NAT for internet access..."
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
echo "  Using interface: $INTERFACE"

echo "  Installing iptables-persistent..."
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
apt-get install -y iptables-persistent

iptables -t nat -C POSTROUTING -s $VPN_CLIENT_SUBNET/24 -o $INTERFACE -j MASQUERADE 2>/dev/null || \
    iptables -t nat -A POSTROUTING -s $VPN_CLIENT_SUBNET/24 -o $INTERFACE -j MASQUERADE

netfilter-persistent save

echo "✓ NAT configured"

##############################################
# Apply Configuration
##############################################

echo ""
echo "Step 8: Applying configuration and restarting OpenVPN..."
/usr/local/openvpn_as/scripts/sacli start
sleep 10
echo "✓ Configuration applied"

##############################################
# Helper function to get metadata
##############################################

get_metadata() {
    local path=$1
    local result=""
    
    # Try IMDSv2 first
    TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
        -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
        -s --max-time 5 2>/dev/null)
    
    if [ -n "$TOKEN" ]; then
        result=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
            -s --max-time 5 \
            "http://169.254.169.254/latest/meta-data/$path" 2>/dev/null)
    fi
    
    # Fallback to IMDSv1
    if [ -z "$result" ]; then
        result=$(curl -s --max-time 5 \
            "http://169.254.169.254/latest/meta-data/$path" 2>/dev/null)
    fi
    
    echo "$result"
}

##############################################
# Create Summary
##############################################

echo ""
echo "Step 9: Creating setup summary..."

# Get instance metadata
INSTANCE_ID=$(get_metadata "instance-id")
PUBLIC_IP=$(get_metadata "public-ipv4")

echo "Retrieved from metadata service:"
echo "  Instance ID: ${INSTANCE_ID:-not available}"
echo "  Public IP: ${PUBLIC_IP:-not available}"

# AWS CLI fallback for public IP
if [ -z "$PUBLIC_IP" ] && [ -n "$INSTANCE_ID" ] && [ "$INSTANCE_ID" != "unknown" ]; then
    echo "Trying AWS CLI to get public IP..."
    PUBLIC_IP=$(/usr/local/bin/aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --region "$REGION" \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text 2>/dev/null)
    
    if [ "$PUBLIC_IP" == "None" ]; then
        PUBLIC_IP=""
    fi
fi

# Network interface fallback
if [ -z "$PUBLIC_IP" ]; then
    echo "Trying to get IP from network interface..."
    PUBLIC_IP=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n1)
fi

# Set defaults if still empty
[ -z "$INSTANCE_ID" ] && INSTANCE_ID="unknown"
[ -z "$PUBLIC_IP" ] && PUBLIC_IP="<check-aws-console-for-public-ip>"

echo ""
echo "Final values:"
echo "  Instance ID: $INSTANCE_ID"
echo "  Public IP: $PUBLIC_IP"

cat > /root/openvpn-setup-summary.txt << EOF
========================================
OpenVPN Access Server - Setup Summary
========================================
Instance ID: $INSTANCE_ID
Public IP: $PUBLIC_IP
Configuration completed at: $(date)

Admin Access:
  Admin UI:  https://$PUBLIC_IP:943/admin
  Client UI: https://$PUBLIC_IP:943/
  
Credentials:
  Username: $ADMIN_USER
  Password: [Retrieved from Secrets Manager]

Configuration:
  - Full Tunnel Mode: ENABLED
  - VPC CIDR: $VPC_CIDR
  - NAT Routing: ENABLED
  - Gateway Access: ENABLED
  - Inter-client Communication: ENABLED
  - CloudWatch Logging: ENABLED
  - CloudWatch Metrics: ENABLED
  
CloudWatch Log Groups:
  - /aws/ec2/openvpn (setup, openvpnas, syslog)
  
CloudWatch Metrics Namespace:
  - OpenVPN/Server (CPU, Memory, Disk, Network)
  
Next Steps:
  1. Access the client portal: https://$PUBLIC_IP:943/
  2. Login with credentials from Secrets Manager
  3. Download your .ovpn profile
  4. Connect and verify your IP shows: $PUBLIC_IP
  5. View logs in CloudWatch: /aws/ec2/openvpn

Logs:
  Setup log: $LOG_FILE
  OpenVPN log: /var/log/openvpnas.log
  
Troubleshooting:
  - If IP shows as placeholder, check AWS Console for actual public IP
  - SSH: ssh -i your-key.pem openvpnas@$PUBLIC_IP
  - View this summary: cat /root/openvpn-setup-summary.txt
  - Check logs: tail -f /var/log/openvpn-setup.log
========================================
EOF

chmod 600 /root/openvpn-setup-summary.txt

echo ""
echo "=========================================="
echo "OpenVPN Setup Complete!"
echo "=========================================="
echo ""
cat /root/openvpn-setup-summary.txt
echo ""
echo "Setup log available at: $LOG_FILE"
echo ""