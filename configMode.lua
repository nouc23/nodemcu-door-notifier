-- setup AP
print("Setup Access Point")
ipcfg = {}
ipcfg.ip="192.168.1.1"
ipcfg.netmask="255.255.255.0"
ipcfg.gateway="192.168.1.1"
wifi.ap.setip(ipcfg)
 
cfg={}
cfg.ssid="door-notifier"
cfg.pwd="12345678"
wifi.ap.config(cfg)
 
print("Starting AP with", cfg.ssid, cfg.pwd)
wifi.setmode(wifi.SOFTAP)

-- setup http
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
  conn:on("receive",function(conn,payload)

    --check is POST request
    if string.sub(payload,1,string.len("POST")) == "POST" then
    	-- get request
		requestLines = lines(payload)
		requestParamsString = (requestLines[table.getn(requestLines)])
    	print("POST request", requestParamsString)


    end

	if file.open("config.html") then
    	conn:send(file.read())
	  	file.close()
	end

  end)
  conn:on("sent",function(conn) conn:close() end)
end)


function lines(str)
  local t = {}
  local function helper(line) table.insert(t, line) return "" end
  helper((str:gsub("(.-)\r?\n", helper)))
  return t
end
