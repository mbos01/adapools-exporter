# adapools-exporter
Metrics exporter for Prometheus

In the search of a way to use [Adapools](https://www.adapools.org) data as metrics for my own Cardano stakepool [the ADA house](https://the.adahou.se) I came across this idea from [Crypto2099](https://crypto2099.io/adding-pool-stats-to-grafana-dashboard/). Because I did not want to use node-exporter to serve the metrics I chose to port it to a Python script that fetches the data for me and then serves it with the use of the [Python http.server lib](https://docs.python.org/3/library/http.server.html).

As per best practice the script should be installed on the same server Prometheus is running on, using the same user Prometheus is running with. This prohibits exposing any ports.

Prerequisites:
-------------
* Python 3.8
* Prometheus

Installation:
-------------
1. Installing Python3. 
   > If you already have python installed, you can skip this step.
   ```
   sudo apt-get update
   sudo apt-get install software-properties-common
   sudo add-apt-repository ppa:deadsnakes/ppa
   sudo apt-get update
   sudo apt-get install python3.8
   ```

2. Downloading adapools-exporter
   ```
   mkdir /opt/adapools-exporter
   sudo wget -O /opt/adapools-exporter/adapools-exporter.py https://raw.githubusercontent.com/mbos01/adapools-exporter/main/adapools-exporter.py
   ```

3. Create a systemd service configuration file for adapools-exporter
   ```
   sudo nano /etc/systemd/system/adapools-exporter.service
   ```
   > Warning: If you want the script to run as a different user, follow the "Optional Steps" bellow.
   ```
   [Unit]
   Description=Adapools exporter
   After=network-online.target
   
   [Service]
   Type=simple
   User=$(whoami)
   WorkingDirectory=/opt/adapools-exporter
   ExecStart=/usr/bin/python3 /opt/adapools-exporter/adapools-exporter.py
   StandardOutput=null
   Restart=always
   
   [Install]
   WantedBy=multi-user.target
   ```

4. Edit the `prometheus.yml` to include `adapools-exporter` as a job.
   ```
   sudo nano /path/to/prometheus.yml
   ```
   ```
   # Don't forget to update YOUR_POOL_ID bellow
   # Update OPTIONAL_CUSTOM_PREFIX if you don't want to see "adapool_" in prometheus
   
   - job_name: adapools-exporter
     scrape_interval: 60s
     metrics_path: /poolid=YOUR_POOL_ID+prefix=OPTIONAL_CUSTOM_PREFIX
     static_configs:
     - targets: ['127.0.0.1:8000']
   ```

5. Add `adapools-exporter` to systemd
   ```
   sudo systemctl daemon-reload
   sudo systemctl enable adapools-exporter.service
   sudo systemctl start adapools-exporter.service
   ```

6. Check to make sure its running
   > If adapools-exporter is not running, check the "Common Issues" section bellow
   ```
   sudo systemctl status adapools-exporter.service
   ```

7. If everything is running smoothly, restart `prometheus.service`
   ```
   sudo systemctl restart prometheus.service
   ```
- metrics will be available in Prometheus:<p>
![alt text](https://github.com/mbos01/adapools-exporter/blob/main/adapools.png?raw=true)

Optional Steps:
-------------
1. By default, adapools runs on port `8080`. To change it, edit `http_port`
   ```
   sudo nano /opt/adapools-exporter/adapools-exporter.py
   
   ...
   
   ### SETTINGS ####################################################################################
   http_port = 8000 #webserver port
   http_address = "localhost" #webserver is listening on this address
   #################################################################################################
   
   ...
   ```
2. To run adapools-exporter as a different user, we need to change the permissions and update the `adapools-exporter.service`
   ```
   sudo chown -R <username>:<username> /opt/adapools-exporter
   ```
   ```
   sudo nano /etc/systemd/system/adapools-exporter.service
   
   ...
   # Change this to the desired username
   User=<username>
   ...
   
   ```
3. If you made any changes above, reload `adapools-exporter.service`
   ```
   sudo systemctl daemon-reload
   sudo systemctl enable adapools-exporter.service
   sudo systemctl start adapools-exporter.service
   ```

Common Issues:
-------------