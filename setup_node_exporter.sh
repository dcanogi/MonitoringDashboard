#!/bin/bash

# Define variables
NODE_EXPORTER_VERSION="1.5.0"
NODE_EXPORTER_TAR="node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
NODE_EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/${NODE_EXPORTER_TAR}"
NODE_EXPORTER_DIR="/tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64"

# Download and Install Node Exporter
echo "Downloading Node Exporter..."
cd /tmp
curl -LO "${NODE_EXPORTER_URL}"
tar xvfz "${NODE_EXPORTER_TAR}"
cd "${NODE_EXPORTER_DIR}"

echo "Installing Node Exporter..."
sudo mv node_exporter /usr/local/bin/

# Create a Systemd Service for Node Exporter
echo "Creating Node Exporter systemd service..."
cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Start and Enable Node Exporter
echo "Starting and enabling Node Exporter..."
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Update Prometheus Configuration
echo "Updating Prometheus configuration..."
PROMETHEUS_CONFIG="/etc/prometheus/prometheus.yml"

# Check if Node Exporter job already exists
if grep -q 'node_exporter' "$PROMETHEUS_CONFIG"; then
    echo "Node Exporter already configured in Prometheus."
else
    echo "Adding Node Exporter job to Prometheus configuration..."
    sudo tee -a "$PROMETHEUS_CONFIG" <<EOF
- job_name: 'node_exporter'
  static_configs:
    - targets: ['localhost:9100']  # Default port for Node Exporter
EOF
fi

# Restart Prometheus
echo "Restarting Prometheus..."
sudo systemctl restart prometheus

echo "Setup complete."