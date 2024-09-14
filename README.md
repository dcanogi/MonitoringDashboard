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
## Setup Node Exporter
Download and Install Node Exporter
### Download Node Exporter:

Navigate to the /tmp directory and download the Node Exporter tarball. For version 1.5.0, use the following commands:

```bash
cd /tmp
curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
```
### Extract Node Exporter:

Extract the downloaded tarball:

```bash
tar xvfz node_exporter-1.5.0.linux-amd64.tar.gz
```
### Navigate to the extracted directory:

```bash
cd node_exporter-1.5.0.linux-amd64
```
### Move Node Exporter Binaries:

Move the node_exporter binary to /usr/local/bin/:

```bash
sudo mv node_exporter /usr/local/bin/
```
### Create a Systemd Service for Node Exporter:

Create a systemd service file to manage Node Exporter as a service:

```bash
sudo nano /etc/systemd/system/node_exporter.service
```
### Add the following content to the file:

```bash
[Unit]
Description=Node Exporter
After=network.target

[Service]
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```
### Start and Enable Node Exporter:

Reload systemd to recognize the new service, then start and enable Node Exporter to start on boot:

```bash
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
```
### Verify Node Exporter is Running:

Check the status of the Node Exporter service to ensure it is running:

```bash
sudo systemctl status node_exporter
```
### Update Prometheus Configuration
To have Prometheus scrape metrics from Node Exporter, you need to update its configuration file.

### Edit Prometheus Configuration:

Open the Prometheus configuration file:

```bash
sudo nano /etc/prometheus/prometheus.yml
```

### Add Node Exporter Job:

Add the following job configuration to the prometheus.yml file. This configuration specifies that Prometheus should scrape metrics from Node Exporter running on localhost:9100:

```bash
- job_name: 'node_exporter'
  static_configs:
    - targets: ['localhost:9100']
```
### Restart Prometheus:

Apply the changes by restarting Prometheus:

```bash
sudo systemctl restart prometheus
```
### Verify Integration
Check Prometheus Targets:

Open Prometheus web interface at http://localhost:9090 and go to the "Targets" page to verify that Node Exporter is listed and being scraped correctly.

### Access Node Exporter Metrics:

You can also verify that Node Exporter is providing metrics by accessing its web interface at http://localhost:9100/metrics.

### Troubleshooting
If you encounter any issues with updating the Prometheus configuration or ensuring that Node Exporter is properly integrated, you can use the script update_prometheus_config.sh to help automate the configuration update.

#### To use the script:

Save the Script:

Save the following script as update_prometheus_config.sh:

```bash
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
```
#### Make the Script Executable:

cbash
chmod +x update_prometheus_config.sh
```
Run the Script:

```bash
sudo ./update_prometheus_config.sh
```

## Add Prometheus Dashboard in Grafana
Add Prometheus Data Source
### Log in to Grafana:

Open Grafana in your web browser at http://localhost:3000 and log in using the default credentials:

- **Username**: `admin`
- **Password**: `admin` 

### Add Data Source:

Click on the gear icon (⚙️) on the left sidebar to open the Configuration menu.

Select Data Sources from the menu.

Click the Add data source button.

### Select Prometheus:

Choose Prometheus from the list of available data sources.
Configure Prometheus Data Source:

In the HTTP section, set the URL to your Prometheus server. For local Prometheus, use http://localhost:9090.

Click Save & Test to verify the connection to Prometheus.

### Import Prometheus Dashboard

Click on the plus icon (+) on the left sidebar and select Import.

You can either upload a JSON file of a dashboard or use a dashboard ID from the Grafana community. For example, the official Prometheus dashboard ID is 11074.

#### Configure Dashboard:

If using a dashboard ID, enter the ID in the Import via grafana.com field and click Load.

Select the Prometheus data source you configured earlier in the Select Prometheus dropdown.

Click Import to add the dashboard to your Grafana instance.
Add Queries to Dashboard Panels

#### Edit Panel:

Open the imported dashboard and hover over a panel you want to edit.
Click the title of the panel and select Edit.

#### Add Prometheus Query:

Go to the Queries tab.

Select Prometheus as the data source (if not already selected).

Enter your Prometheus query in the query field. 

Examples on query.md

#### Configure Panel:

Adjust the panel settings such as visualization type, axes, and legends to fit your needs.

Click Apply to save changes to the panel.

#### Save Dashboard:

Click the Save dashboard icon (💾) on the top right corner to save your dashboard with the newly added panels and queries.

## Grafana Alerts
Configuring Alerts
To configure alerts in Grafana:

Navigate to Alerts: Go to the Alerting section in Grafana.
Create Alert: Set up a new alert rule and define the query and conditions for the alert.
Example Alert Query
For a CPU usage alert if it exceeds 1%:

```promql
node_cpu_seconds_total{mode="idle"} / ignoring(mode) group_left sum(node_cpu_seconds_total) * 100 < 99
```
This query checks if the CPU usage is above 1%.

### Configuring Slack for Grafana Alerts

1. #### Create a New App in Slack

Go to the Slack API Page:

Visit https://api.slack.com/apps.

Create a New App:

Click on Create New App.

Choose a name for the app and select the workspace where you want it to work.

Configure Permissions:

In the OAuth & Permissions section, add the `chat:write.public` scope to allow your app to post messages in all public channels without joining them.

In OAuth Tokens for Your Workspace, copy the Bot User OAuth Token that starts with “xoxb-”.

### Obtain the Channel ID:

- Open your Slack workspace.

- Right-click on the channel where you want to receive notifications.

- Click View channel details.

    - Copy the Channel ID.


2. #### Configure Grafana to Use Slack
Access Grafana:

- Open Grafana and go to Alerting > Contact points.

- Add a New Contact Point:

    - Click on + Add contact point.

        - Enter a name for the contact point.

        - Select Slack as Integration:

        - From the list of integrations, select Slack.

        - Configure the Contact Point:

        - If using a Slack API Token:

        - In the Recipient field, enter the Channel ID copied earlier.

        - In the Token field, enter the Bot User OAuth Token copied earlier.


### Test the Integration:

Click Test to ensure that the integration works.

Save the Contact Point:

Click Save contact point.

4. #### Add the Contact Point to an Alert Rule
Access Alert Rules:

In Grafana, go to Alerting > Alert rules.

Edit or Create a New Rule:

Edit an existing rule or create a new one.

Configure Labels and Notifications:

In the Configure labels and notifications section, under Notifications, select the previously created contact point.

Save the Rule:

Click Save rule and exit.