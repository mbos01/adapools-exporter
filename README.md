# adapools-exporter
Metrics exporter for Prometheus

In the search of a way to use [Adapools](https://www.adapools.org) data as metrics for my own Cardano stakepool [the ADA house](https://the.adahou.se) I came across this idea from [Crypto2099](https://crypto2099.io/adding-pool-stats-to-grafana-dashboard/). Because I did not want to use node-exporter to serve the metrics I chose to port it to a Python script that fetches the data for me and then serves it with the use of the [Python http.server lib](https://docs.python.org/3/library/http.server.html).

As per best practice the script should be installed on the same server Prometheus is running on, using the same user Prometheus is running with. This prohibits exposing any ports.

# Prerequisites
* Python 3.8
* Prometheus

# Installation
1. Installing Python3. 
   > If you already have python installed, you can skip this step.
   ```
   sudo apt-get update
   sudo apt-get install software-properties-common
   sudo add-apt-repository ppa:deadsnakes/ppa
   sudo apt-get update
   sudo apt-get install python3.8
   ```

2. Download `adapools-exporter`
   ```
   mkdir /opt/adapools-exporter
   cd /opt/adapools-exporter
   sudo https://raw.githubusercontent.com/mbos01/adapools-exporter/main/adapools-exporter.py
   ```

3. Change folder ownership to `prometheus`
   > Warning: If you want the script to run as a different user, go to [`"Run adapools-exporter as a different user"`](#run-adapools-exporter-as-a-different-user) bellow. Once that's completed, skip step 4 bellow and go to step 5.
   ```
   sudo chown -R prometheus:prometheus /opt/adapools-exporter
   ```
   
4. Create a systemd service configuration file for `adapools-exporter`
   ```
   sudo nano /etc/systemd/system/adapools-exporter.service
   ```
   
   ```
   [Unit]
   Description=Adapools exporter
   After=network-online.target
   
   [Service]
   Type=simple
   User=prometheus
   WorkingDirectory=/opt/adapools-exporter
   ExecStart=/usr/bin/python3 /opt/adapools-exporter/adapools-exporter.py
   StandardOutput=null
   Restart=always
   
   [Install]
   WantedBy=multi-user.target
   ```

5. Edit the `prometheus.yml` to include `adapools-exporter` as a job.
   ```
   sudo nano /path/to/prometheus.yml
   ```
   ```
   # Paste this under "scrape_configs"
   # Don't forget to update YOUR_POOL_ID bellow
   # Update OPTIONAL_CUSTOM_PREFIX if you don't want to see "adapool_" in prometheus
   
   - job_name: 'adapools-exporter'
     scrape_interval: 60s
     metrics_path: /poolid=YOUR_POOL_ID+prefix=OPTIONAL_CUSTOM_PREFIX
     static_configs:
     - targets: ['127.0.0.1:8000']
   ```

6. Add `adapools-exporter` to systemd
   ```
   sudo systemctl daemon-reload
   sudo systemctl enable adapools-exporter.service
   sudo systemctl start adapools-exporter.service
   ```

7. Check to make sure its running
   > If adapools-exporter is not running, check the [`"Common Issues"`](#common-issues) section bellow
   ```
   sudo systemctl status adapools-exporter.service
   
   # Output
   * adapools-exporter.service - Adapools exporter
        Loaded: loaded (/etc/systemd/system/adapools-exporter.service; enabled; vendor preset: enabled)
        Active: active (running) since Wed 2020-12-09 02:17:00 UTC; 14h ago
      Main PID: 4079693 (python3)
         Tasks: 1 (limit: 4683)
        Memory: 18.9M
        CGroup: /system.slice/adapools-exporter.service
   ```

8. If everything is running smoothly, restart `prometheus.service`
   ```
   sudo systemctl restart prometheus.service
   ```

9. Check if `prometheus.service` is running
   ```
   sudo systemctl status prometheus.service
   
   # Output
   * prometheus.service - Prometheus Server
        Loaded: loaded (/etc/systemd/system/prometheus.service; enabled; vendor preset: enabled)
        Active: active (running) since Wed 2020-12-09 02:30:36 UTC; 14h ago
          Docs: https://prometheus.io/docs/introduction/overview/
      Main PID: 4079964 (prometheus)
         Tasks: 10 (limit: 4683)
        Memory: 117.8M
        CGroup: /system.slice/prometheus.service
   ```
Well done!
Metrics will now be available in Prometheus:<p>
![alt text](https://github.com/mbos01/adapools-exporter/blob/main/adapools.png?raw=true)

# Optional Steps

### Change default port
By default, adapools runs on port `8080`. To change it, edit `http_port` under `SETTINGS`
```
sudo nano /opt/adapools-exporter/adapools-exporter.py

...

### SETTINGS ####################################################################################
http_port = 8000 #webserver port
http_address = "localhost" #webserver is listening on this address
#################################################################################################

...
```

### Run adapools-exporter as a different user
To run `adapools-exporter` as a different user other than prometheus, we need to change the folder's ownership to the desired user.
```
# Change <username> to the desired username
sudo chown -R <username>:<username> /opt/adapools-exporter
```

Open `adapools-exporter.service` for us to modify the `User` config

```
sudo nano /etc/systemd/system/adapools-exporter.service
```

If this file is empty, then copy the block bellow and update `<username>`.
If this file is not empty, look for `"User=<username>"` and update `<username>` with the user you used in the previous step.

```
[Unit]
Description=Adapools exporter
After=network-online.target

[Service]
Type=simple
User=<username> # Change this to the desired username
WorkingDirectory=/opt/adapools-exporter
ExecStart=/usr/bin/python3 /opt/adapools-exporter/adapools-exporter.py
StandardOutput=null
Restart=always

[Install]
WantedBy=multi-user.target
```

If you made any changes above, reload `adapools-exporter.service`
```
sudo systemctl daemon-reload
sudo systemctl enable adapools-exporter.service
sudo systemctl start adapools-exporter.service
```

# Common Issues
### Adapools-exporter wont start
```
* adapools-exporter.service - Adapools exporter
     Loaded: loaded (/etc/systemd/system/adapools-exporter.service; enabled; vendor preset: enabled)
     Active: failed (Result: exit-code) since Wed 2020-12-09 17:35:40 UTC; 254ms ago
    Process: 81106 ExecStart=/usr/bin/python3 /opt/adapools-exporter/adapools-exporter.py (code=exited, status=217/USER)
   Main PID: 81106 (code=exited, status=217/USER)
```
If you see the following error (`status=217/USER`), that means that `adapools-exporter.service` is configured with an invalid username. 
This is most likely caused by you not having the user `prometheus` in your system. You can either create it, or user a different username (See: [`Run adapools-exporter as a different user`](#run-adapools-exporter-as-a-different-user) above)

### Prometheus wont start after I made my changes
```
* prometheus.service - Prometheus Server
     Loaded: loaded (/etc/systemd/system/prometheus.service; enabled; vendor preset: enabled)
     Active: failed (Result: exit-code) since Wed 2020-12-09 17:55:02 UTC; 3s ago
       Docs: https://prometheus.io/docs/introduction/overview/
    Process: 81306
   Main PID: 81306 (code=exited, status=2)
```
This is likely caused by the changes we made to `prometheus.yml`.
This file is really picky when it comes to spaces and indentations. You probably added a `tab` character or an extra space by mistake somewhere.
If you have `promtools` installed you can run the following command to validate your `prometheus.yml` file.
If you don't have `promtools`, you will need to validate the file manually.
```
./promtool check config prometheus.yml
```

### Pool stats aren't available in Prometheus
If you're unable to see your new job in prometheus, that means there's something wrong with the config.
Please double check all the spacings are correct and remove any `tab characters`. 
