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
- sudo systemctl daemon-reload
- sudo systemctl enable adapools-exporter.service
- sudo systemctl start adapools-exporter.service
- sudo nano /etc/prometheus/prometheus.yml
- sudo systemctl restart prometheus.service
- metrics will be available in Prometheus:<p>
![alt text](https://github.com/mbos01/adapools-exporter/blob/main/adapools.png?raw=true)
