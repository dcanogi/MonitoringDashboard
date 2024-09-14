#!/bin/bash

# Exit if any command fails
set -e

# Install necessary dependencies
echo "Installing dependencies..."
sudo apt-get install -y apt-transport-https software-properties-common wget

# Add Grafana GPG key
echo "Adding Grafana GPG key..."
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

# Add Grafana APT repository
echo "Adding Grafana repository..."
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# Update package list
echo "Updating package list..."
sudo apt-get update

# Install Grafana
echo "Installing Grafana..."
sudo apt-get install -y grafana

# Reload systemd and enable/start Grafana
echo "Starting and enabling Grafana service..."
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server

# Check Grafana status
echo "Checking Grafana status..."
sudo systemctl status grafana-server

echo "Grafana has been successfully installed."
