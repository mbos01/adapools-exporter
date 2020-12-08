import requests, json, time, os
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib import parse

### SETTINGS ####################################################################################
delkeys = "hist_bpe,handles,hist_roa,db_ticker,db_name,db_url,ticker_orig,pool_id,db_description,direct,stake_x_deleg,group_basic" #no metric data
http_port = 8000 #webserver port
http_address = "localhost" #webserver is listening on this address
#################################################################################################

def makeHandler(url, delkeys):
    class getHandler(BaseHTTPRequestHandler):
        def getPoolData(self, url, delkeys, prefix): #fetch adapools data
            pooldata = []
            try:
                r = json.loads(requests.get(url).text)
            except:
                pooldata.append("Error scraping pooldata")
                return pooldata

            delkeys = (delkeys).split(",") #exclude these
            for key in r["data"]:
                if key not in delkeys:
                    a = str(key)
                    b = str(r["data"][key])
                    pooldata.append(prefix + a + " " + b.lower().replace("none", "0"))

            return pooldata #return list

        def do_GET(self):
            parsed_url = parse.urlparse(self.path) #parse url

            if (len(parsed_url.path.split("poolid=")) < 2):
                print("No pool id!") #there's no pool id
                return
            else:
                poolid = parsed_url.path.split("poolid=")[1].split("+")[0]

                #is prefix sent along?
                if (len(parsed_url.path.split("prefix=")) < 2): #no custom prefix
                    prefix = "adapools_"
                else:
                    prefix = parsed_url.path.split("prefix=")[1] #use custom prefix

            pooldata = self.getPoolData(url.replace("[POOLID]", poolid), delkeys, prefix)
            html = "\n".join(pooldata)

			#send output to client
            self.send_response(200)
            self.send_header('Content-Type',
                            'text/plain; charset=utf-8')
            self.end_headers()
            self.wfile.write(html.encode('utf-8'))

            return
    return getHandler

# no need to change these!! #####################################################################
url = "https://js.adapools.org/pools/[POOLID]/summary.json" #adapools json
delkeys = "hist_bpe,handles,hist_roa,db_ticker,db_name,db_url,ticker_orig,pool_id,db_description,direct,stake_x_deleg,group_basic" 
#################################################################################################

try:
	#spawn webserver
	httpd = HTTPServer((http_address, http_port), makeHandler(url, delkeys))
	print("Serving Adapools metrics at " + str(http_address) + ":" + str(http_port))
	httpd.serve_forever()
except KeyboardInterrupt:
	httpd.shutdown()
