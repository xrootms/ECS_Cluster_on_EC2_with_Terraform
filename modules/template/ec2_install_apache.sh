#!/bin/bash
set -x

sudo apt update -y
sudo apt install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2

# -------------------------------
# Get IMDSv2 token
# -------------------------------
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# -------------------------------
# Fetch instance metadata
# -------------------------------
instanceId=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
instanceAZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)
pubHostName=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-hostname)
pubIPv4=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
privHostName=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-hostname)
privIPv4=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)

# -------------------------------
# Build HTML page
# -------------------------------
cat <<EOF > /var/www/html/index.html
<font face="Verdana" size="5">
<center><h1>Bastion Host Deployed with Terraform</h1></center>
<center><b>EC2 Instance Metadata</b></center>
<center><b>Instance ID:</b> $instanceId</center>
<center><b>AWS Availability Zone:</b> $instanceAZ</center>
<center><b>Public Hostname:</b> $pubHostName</center>
<center><b>Public IPv4:</b> $pubIPv4</center>
<center><b>Private Hostname:</b> $privHostName</center>
<center><b>Private IPv4:</b> $privIPv4</center>
</font>
EOF
