require 'config'

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
		if file.open("config.data", "w+") then
		  file.write(requestParamsString)
		  file.close()
		end
    end

    --load config
    config = load_config()

--    for key, value in pairs(config) do
--        print (key, value)
--    end

	-- load html
	if file.open("config.html") then
		html = file.read()
        file.close()
        
		-- simple html template variables parse
        for key, value in pairs(config) do
            -- @todo add to value html escape
            html = html:gsub('%[%[' .. key .. '%]%]', value)
        end
        
        -- removing missing configurations
        html = html:gsub('%[%[(.-)%]%]', '')

    	conn:send(html)
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
