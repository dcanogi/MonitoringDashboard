# MonitoringDashboard
Monitoring Dashboard using Grafana and Runscope
Install Dependencies:

Begin by installing the necessary dependencies for handling HTTPS transport and managing repositories.

sudo apt-get install -y apt-transport-https software-properties-common wget
Add the Grafana GPG Key:

To securely download Grafana, add its GPG key and store it in /etc/apt/keyrings/.

sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
Add the Grafana APT Repository:

Now, add the Grafana repository to your system's sources list.

echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
Update the Package List:

Update your system's package index to include the new Grafana repository.

sudo apt-get update
Install Grafana:

Install the latest version of Grafana.

sudo apt-get install grafana
Start and Enable Grafana Service:

After installing Grafana, reload the system daemon and ensure that Grafana starts on boot.

sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
Access Grafana:

Grafana should now be running on http://localhost:3000. You can log in with the default credentials:

Username: admin
Password: admin (you will be prompted to change this upon first login).