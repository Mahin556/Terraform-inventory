#!/bin/bash

# Update packages
yum update -y

# Install Apache
yum install -y httpd
systemctl enable --now httpd

# Fetch IMDSv2 token
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
       -H "X-aws-ec2-metadata-token-ttl-seconds: 300")

# Fetch instance ID using IMDSv2
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
       http://169.254.169.254/latest/meta-data/instance-id)

# Write content to index.html
echo "Hello from Backend Instance-${INSTANCE_ID}" > /var/www/html/index.html