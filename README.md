# adapools-exporter
Metrics exporter for Prometheus

In the search of a way to use [Adapools](https://www.adapools.org) data as metrics for my own Cardano stakepool [the ADA house](https://the.adahou.se) I came across this idea from [Crypto2099](https://crypto2099.io/adding-pool-stats-to-grafana-dashboard/). Because I did not want to use node-exporter to serve the metrics I chose to port it to a Python script that fetches the data for me and then serves it with the use of the [Python http.server lib](https://docs.python.org/3/library/http.server.html).

Please note that in the below installation guide I assume Python3 is installed and the adapools-exporter is running on the same machine Prometheus is running on.

Installation:
-------------
+ cd /opt
+ git clone https://github.com/mbos01/adapools-exporter.git
+ cd adapools-exporter
+ nano adapools-exporter.py 
+ adjust url and insert your own pool id:

    url = "https://js.adapools.org/pools/!!!!!YOUR-POOL-ID!!!!!/summary.json" #adapools json<br>
+ save and close nano
+ sudo nano /etc/systemd/system/adapools-exporter.service
+ paste the following:

    [Unit]<br>
    Description=Adapools exporter<br>
    After=network-online.target<br>
    <br>
    [Service]<br>
    Type=simple<br>
    User=prometheus<br>
    Group=prometheus<br>
    WorkingDirectory=/opt/adapools-exporter<br>
    ExecStart=/usr/bin/python3 /opt/adapools-exporter/adapools-exporter.py<br>
    StandardOutput=null<br>
    Restart=always<br>
    <br>
    [Install]<br>
    WantedBy=multi-user.target<br>

+ save and close nano
+ sudo systemctl enable adapools-exporter
+ sudo systemctl daemon-reload
+ sudo service adapools-exporter start

+ add new job to /etc/prometheus/prometheus.yaml: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;***mind the traling slash in the metrics path**

    \- job_name: adapools-exporter<br>
    &nbsp;&nbsp;&nbsp;&nbsp;scrape_interval: 15s<br>
    &nbsp;&nbsp;&nbsp;&nbsp;metrics_path: /metrics/<br>
    &nbsp;&nbsp;&nbsp;&nbsp;static_configs:<br>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\- targets: ['127.0.0.1:8000']<br>
    
+ sudo service prometheus restart 
+ metrics will now be available in Prometheus:<p>
![alt text](https://github.com/mbos01/adapools-exporter/blob/main/adapools.png?raw=true)
