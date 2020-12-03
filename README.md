# adapools-exporter
Metrics exporter for Prometheus

Original idea from Crypto2099: https://crypto2099.io/adding-pool-stats-to-grafana-dashboard/

Installation:
-------------
+ cd /opt
+ git clone https://github.com/mbos01/adapools-exporter.git
+ cd adapools-exporter
+ nano adapools-exporter.py 
+ adjust url and insert you pool id:

    url = "https://js.adapools.org/pools/!!!!!YOUR-POOL-ID!!!!!/summary.json" #adapools json<br>
+ save and close nano
+ sudo nano /etc/systemd/system/adapools-exporter.service
+ paste the following:

    [Unit]<br>
    Description=Adapool exporter<br>
    After=network-online.target<br>
    <br>
    [Service]<br>
    WorkingDirectory=/opt/pool.stats<br>
    ExecStart=/usr/bin/[PYTHON VERSION] /opt/adapools-exporter/adapools-exporter.py<br>
    StandardOutput=null<br>
    <br>
    [Install]<br>
    WantedBy=multi-user.target<br>

+ save and close nano
+ sudo systemctl enable adapools-exporter
+ sudo systemctl daemon-reload
+ sudo service adapools-exporter start

+ add new job to /etc/prometheus/prometheus.yaml:

  \- job_name: adapools<br>
  &nbsp;&nbsp;&nbsp;&nbsp;scrape_interval: 15s<br>
  &nbsp;&nbsp;&nbsp;&nbsp;metrics_path: /metrics/ <-- the python http.server component expects this trailing slash<br>
  &nbsp;&nbsp;&nbsp;&nbsp;static_configs:<br>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\- targets: ['127.0.0.1:8000']<br>
+ sudo service prometheus restart 
+ metrics will now be available in Prometheus
