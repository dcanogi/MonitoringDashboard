#!/bin/bash

# Define variables
PROMETHEUS_CONFIG="/etc/prometheus/prometheus.yml"
BACKUP_CONFIG="/etc/prometheus/prometheus.yml.bak"
CORRECTED_CONFIG="/tmp/prometheus_corrected.yml"

# Backup current Prometheus configuration
echo "Backing up current Prometheus configuration..."
sudo cp "$PROMETHEUS_CONFIG" "$BACKUP_CONFIG"

# Create a corrected Prometheus configuration
echo "Creating corrected Prometheus configuration..."
cat <<EOF | sudo tee "$CORRECTED_CONFIG"
---
# Global configuration
global:
  scrape_interval: 15s  # Interval between each scrape

# Scrape configuration
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']  # Monitor Prometheus itself

  - job_name: 'my_application'
    static_configs:
      - targets: ['localhost:8080']  # Replace with your application's address

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']  # Default port for Node Exporter
EOF

# Replace the old configuration with the corrected one
echo "Replacing old configuration with corrected one..."
sudo mv "$CORRECTED_CONFIG" "$PROMETHEUS_CONFIG"

# Restart Prometheus to apply changes
echo "Restarting Prometheus..."
sudo systemctl restart prometheus

# Check Prometheus status
echo "Checking Prometheus status..."
sudo systemctl status prometheus

echo "Setup complete."
