#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -e

apt update -y
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs npm git

# Clone app as root
git clone https://github.com/akkimahesh/apt-assignment.git /app
cd /app/app
npm install

# Systemd service running as ROOT
cat > /etc/systemd/system/app.service << 'EOF'
[Unit]
Description=Node.js App (Root)
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/app/app
Environment=PORT=8080
ExecStart=/usr/bin/node server.js  # Direct node, bypass npm start issues
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable app
systemctl start app

# Health check verification
sleep 15
curl -f http://localhost:8080/ || echo "Health check FAILED" >> /var/log/user-data.log
