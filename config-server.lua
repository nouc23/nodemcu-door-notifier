require 'config'

-- setup http
print('Create server')
srv=net.createServer(net.TCP)
srv:listen(80, function(conn)
    conn:on("receive", function(conn,payload)
        print('Got http request')
    
        --check is POST request
        if string.sub(payload,1,string.len("POST")) == "POST" then

            -- get request
            requestLines = lines(payload)
            requestParamsString = (requestLines[table.getn(requestLines)])
            print("POST request", requestParamsString)

            -- store config
            if file.open("config.data", "w+") then
                print('Saving config')
                file.write(requestParamsString)
                file.close()
            end
        end

        --load config
        print('Load config')
        config = load_config()

        -- send http headers
        print('Send http headers')
        conn:send("HTTP/1.0 200 OK\r\nServer: NodeMCU on ESP8266\r\nContent-Type: text/html\r\n\r\n")

        -- load html
        if file.open("config.html") then
            print('Open template')
        
            local line = file.readline();

            while line ~= nil do
                           
                -- simple html template variables parse
                for key, value in pairs(config) do
                    -- @todo add to value html escape
                    line = line:gsub('%[%[' .. key .. '%]%]', value)
                end
            
                -- removing missing configurations
                line = line:gsub('%[%[(.-)%]%]', '')

                print('Send', line)
              
                -- send html line
                conn:send(line)

                -- load next line
                line = file.readline();
            end

            print('Finish sending response')
            
            file.close()
            
            collectgarbage()

            print('Collect garbage')

                
        end

        
        conn:close() 
    
        print('Connection close')
    end)
    conn:on("sent", function(conn) 
    end)
end)


function lines(str)
    local t = {}
    local function helper(line)
        table.insert(t, line)
        return ""
    end
    helper((str:gsub("(.-)\r?\n", helper)))
    return t
end
