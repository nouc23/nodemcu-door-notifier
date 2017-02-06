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

    	-- store config
		if file.open("config.data", "a+") then
		  file.write(requestParamsString)
		  file.close()
		end
    end

    --load config
    config = {}
	if file.open("config.data") then
		config_string = file.read()
		print("Load config from file")
	  	file.close()

    	config = query_string(config_string)
-- print(config["wifi_pass"])
	end
	

	-- load html
	if file.open("config.html") then
		html = file.read()

		for key, value in pairs(config) do
		    print(key, value)
           -- @todo replace html
	    end

    	conn:send(html)
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

function url_decode (s)
    return s:gsub ('+', ' '):gsub ('%%(%x%x)', function (hex) return string.char (tonumber (hex, 16)) end)
end 

function query_string (url)
    local res = {}

    for name, value in  string.gmatch(url,'([^&=]+)=([^&=]+)') do
        value = url_decode (value)
        name = url_decode (name)
        res [name] = value
    end
    return res
end
