#!/bin/bash

# Exit if any command fails
set -e

# Variables
PROM_VERSION="2.48.0"
PROM_USER="prometheus"
PROM_DIR="/etc/prometheus"
PROM_STORAGE="/var/lib/prometheus"
SERVICE_FILE="/etc/systemd/system/prometheus.service"

# Download Prometheus
echo "Downloading Prometheus..."
cd /tmp
curl -LO https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz

# Extract Prometheus
echo "Extracting Prometheus..."
tar xvfz prometheus-${PROM_VERSION}.linux-amd64.tar.gz
cd prometheus-${PROM_VERSION}.linux-amd64

# Move binaries
echo "Moving binaries..."
sudo mv prometheus /usr/local/bin/
sudo mv promtool /usr/local/bin/

# Create directories and copy config files
echo "Creating directories and configuration..."
sudo mkdir -p ${PROM_DIR} ${PROM_STORAGE}
sudo cp prometheus.yml ${PROM_DIR}/
sudo chown -R ${PROM_USER}:${PROM_USER} ${PROM_DIR} ${PROM_STORAGE}

# Create Prometheus user
echo "Creating user ${PROM_USER}..."
sudo useradd --no-create-home --shell /bin/false ${PROM_USER}

# Create systemd service file
echo "Creating systemd service file..."
sudo bash -c "cat > ${SERVICE_FILE}" <<EOL
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
User=${PROM_USER}
Group=${PROM_USER}
Type=simple
ExecStart=/usr/local/bin/prometheus \\
  --config.file=${PROM_DIR}/prometheus.yml \\
  --storage.tsdb.path=${PROM_STORAGE}/ \\
  --web.console.templates=/usr/local/bin/consoles \\
  --web.console.libraries=/usr/local/bin/console_libraries

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and start Prometheus
echo "Starting Prometheus..."
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

# Check Prometheus status
echo "Checking Prometheus status..."
sudo systemctl status prometheus

echo "Prometheus has been successfully installed."
