# adapools-exporter
Metrics exporter for Prometheus

In the search of a way to use [Adapools](https://www.adapools.org) data as metrics for my own Cardano stakepool [the ADA house](https://the.adahou.se) I came across this idea from [Crypto2099](https://crypto2099.io/adding-pool-stats-to-grafana-dashboard/). Because I did not want to use node-exporter to serve the metrics I chose to port it to a Python script that fetches the data for me and then serves it with the use of the [Python http.server lib](https://docs.python.org/3/library/http.server.html).

As per best practice the script should be installed on the same server Prometheus is running on, using the same user Prometheus is running with. This prohibits exposing any ports.

Installation:
-------------
- mkdir /opt/adapools-exporter
- wget -O /opt/adapools-exporter/adapools-exporter.py https://raw.githubusercontent.com/mbos01/adapools-exporter/main/adapools-exporter.py
- sudo chown -R prometheus:prometheus /opt/adapools-exporter
- sudo nano /etc/systemd/system/adapools-exporter.service
<br>
	[Unit]<br>
	Description=Adapools exporter<br>
	After=network-online.target<br>
<br>
	[Service]<br>
	Type=simple<br>
	User=prometheus<br>
	WorkingDirectory=/opt/adapools-exporter<br>
	ExecStart=$python /opt/adapools-exporter/adapools-exporter.py<br>
	StandardOutput=null<br>
	Restart=always<br>
<br>
	[Install]<br>
	WantedBy=multi-user.target<br>
<br>
- sudo systemctl daemon-reload
- sudo systemctl enable adapools-exporter.service
- sudo systemctl start adapools-exporter.service
- sudo nano /etc/prometheus/prometheus.yml
<br>
add job to prometheus:<br>
<br>
	- job_name: adapools-exporter<br>
	  scrape_interval: 15s<br>
	  metrics_path: /metrics/<br>
	  static_configs:<br>
		- targets: ['127.0.0.1:8000']<br>
<br>	
- sudo systemctl restart prometheus.service
- metrics will be available in Prometheus:<p>
![alt text](https://github.com/mbos01/adapools-exporter/blob/main/adapools.png?raw=true)
