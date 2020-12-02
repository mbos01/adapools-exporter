import requests, json, time, os
from http.server import HTTPServer, SimpleHTTPRequestHandler
from threading import Thread

### SETTINGS ####################################################################################
sec = 600 #scrape every ..
url = "https://js.adapools.org/pools/!!!!!YOUR-POOL-ID!!!!!/summary.json" #adapools json
delkeys = "hist_bpe,handles,hist_roa,db_ticker,db_name,db_url,ticker_orig,pool_id,db_description,direct,stake_x_deleg,group_basic" #no metric data
http_port = 8000 #webserver port
http_address = "localhost" #webserver listening on
prefix = "adapools_" #prefix for use in prometheus
#################################################################################################

#fetch the pool data
def getPoolData(url, delkeys):
	pooldata = []
	try:
		r = json.loads(requests.get(url).text)
	except:
		pooldata.append("Error scraping pooldata")
		return pooldata

	delkeys = (delkeys).split(",")
	for key in r["data"]:
		if key not in delkeys:
			a = str(key)
			b = str(r["data"][key])
			pooldata.append(prefix + a + " " + b.lower().replace("none", "0"))

	return pooldata #return list

#create the metrics folder if it does not exist
if not os.path.exists("metrics"):
	os.makedirs("metrics")

#spawn webserver to serve the metrics
httpd = HTTPServer((http_address, http_port), SimpleHTTPRequestHandler)
thread = Thread(target = httpd.serve_forever)
thread.daemon = True
thread.start()

#scrape adapools
starttime = time.time()
try:
	while True:
		with open("metrics/index.html", "w") as f:
			for item in getPoolData(url, delkeys):
				f.write("%s\n" % item)

		time.sleep(sec - ((time.time() - starttime) % sec))
except KeyboardInterrupt:
	httpd.shutdown()
