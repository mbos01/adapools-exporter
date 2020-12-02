# adapools-exporter
Metrics exporter for Prometheus

Original idea from Crypto2099: https://crypto2099.io/adding-pool-stats-to-grafana-dashboard/

Installation:
-------------
+ cd /opt
+ git clone https://github.com/mbos01/adapools-exporter.git
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
+ open script and adjust the settings:

    sec = 600 #run scrape every sec<br>
    url = "https://js.adapools.org/pools/!!!!!YOUR-POOL-ID!!!!!/summary.json" #adapools json<br>
    delkeys = "hist_bpe,handles,hist_roa,db_ticker,db_name,db_url,ticker_orig,pool_id,db_description,direct,stake_x_deleg,group_basic" #no metric data<br>
    http_port = 8000 #webserver port<br>
    http_address = "localhost" #webserver listening on<br>
    prefix = "adapools_" #prefix for use in prometheus<br>

+ add new job to /etc/prometheus/prometheus.yaml:

  \- job_name: adapools<br>
  &nbsp;&nbsp;&nbsp;&nbsp;scrape_interval: 15s<br>
  &nbsp;&nbsp;&nbsp;&nbsp;metrics_path: /metrics/ <-- the python http.server component expects this trailing slash<br>
  &nbsp;&nbsp;&nbsp;&nbsp;static_configs:<br>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\- targets: ['127.0.0.1:8000']<br>
 
 
