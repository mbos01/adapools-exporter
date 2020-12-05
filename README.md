# adapools-exporter
Metrics exporter for Prometheus

In the search of a way to use [Adapools](https://www.adapools.org) data as metrics for my own Cardano stakepool [the ADA house](https://the.adahou.se) I came across this idea from [Crypto2099](https://crypto2099.io/adding-pool-stats-to-grafana-dashboard/). Because I did not want to use node-exporter to serve the metrics I chose to port it to a Python script that fetches the data for me and then serves it with the use of the [Python http.server lib](https://docs.python.org/3/library/http.server.html).

Please note that in the below installation guide I assume Python3 is installed and the adapools-exporter is running on the same machine Prometheus is running on.

Installation:
-------------
+ wget https://raw.githubusercontent.com/mbos01/adapools-exporter/main/adapools-exporter-installer.sh
+ chmod +x adapools-exporter-installer.sh
+ ./adapools-exporter-installer.sh
+ follow the steps<p>
+ metrics will now be available in Prometheus:<p>
![alt text](https://github.com/mbos01/adapools-exporter/blob/main/adapools.png?raw=true)
