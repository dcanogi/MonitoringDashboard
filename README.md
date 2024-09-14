# MonitoringDashboard
Monitoring Dashboard using Grafana
## Grafana Install
### Install Dependencies:

Begin by installing the necessary dependencies for handling HTTPS transport and managing repositories.

```bash
sudo apt-get install -y apt-transport-https software-properties-common wget
```
### Add the Grafana GPG Key:

To securely download Grafana, add its GPG key and store it in /etc/apt/keyrings/.

```bash
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
```
### Add the Grafana APT Repository:

Now, add the Grafana repository to your system's sources list.

```bash
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
```
### Update the Package List:

Update your system's package index to include the new Grafana repository.

```bash
sudo apt-get update
Install Grafana:
```
### Install the latest version of Grafana.

```bash
sudo apt-get install grafana
```
### Start and Enable Grafana Service:

After installing Grafana, reload the system daemon and ensure that Grafana starts on boot.

```bash
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
```

### Access Grafana:

Grafana should now be running on [http://localhost:3000](http://localhost:3000). You can log in using the default credentials:

- **Username**: `admin`
- **Password**: `admin` 

## Automated Installation Script for Grafana
To automate this process, you can create and run the following script:

Save the script as install_grafana.sh.

Give it execution permissions using:

```bash
chmod +x install_grafana.sh
```
Run the script with superuser privileges:

```bash
sudo ./install_grafana.sh
```
Here's the script for Grafana installation:

```bash
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
```


## Prometheus install

Download Prometheus
Download the latest version of Prometheus from its official GitHub releases.

```bash
cd /tmp
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.48.0/prometheus-2.48.0.linux-amd64.tar.gz
```
### Extract Prometheus

Extract the downloaded archive.

```bash
tar xvfz prometheus-2.48.0.linux-amd64.tar.gz
cd prometheus-2.48.0.linux-amd64
```
### Move Prometheus Binaries

Move the `prometheus` and `promtool` binaries to `/usr/local/bin/`

```bash
sudo mv prometheus /usr/local/bin/
sudo mv promtool /usr/local/bin/
```
### Set Up Directories and Permissions

Create directories for Prometheus configuration and storage, and assign appropriate permissions.

```bash
sudo mkdir /etc/prometheus
sudo cp prometheus.yml /etc/prometheus/
sudo mkdir -p /var/lib/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
```
### Create Prometheus Service
To ensure Prometheus runs as a system service, create a `prometheus.service` file in `/etc/systemd/system/`.

```bash
sudo nano /etc/systemd/system/prometheus.service
```
Add the following content:

```bash
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus/ \
  --web.console.templates=/usr/local/bin/consoles \
  --web.console.libraries=/usr/local/bin/console_libraries

[Install]
WantedBy=multi-user.target
```
### Start and Enable Prometheus

Reload systemd and enable Prometheus to start on boot:
```bash
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
```
### Check Prometheus Status
Verify that Prometheus is running:
```bash
sudo systemctl status prometheus
```
## Access Prometheus

After successfully installing Prometheus and starting the service, you can access the Prometheus web interface to view and query metrics.

### Access Prometheus Web Interface

Prometheus runs on port `9090` by default. You can access the web interface by navigating to the following URL in your web browser:

[http://localhost:9090](http://localhost:9090)

### Default Credentials

Prometheus does not have a default login or password. The web interface is open and accessible without authentication by default.

### Automated Installation Script for Prometheus

You can automate the Prometheus installation by creating a script:

Save the script as `install_prometheus.sh`.

Make it executable:

```bash
chmod +x install_prometheus.sh
```
Run the script with superuser privileges:

```bash
sudo ./install_prometheus.sh
```
Here’s the script for Prometheus installation:
```bash
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
```
