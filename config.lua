function load_config ()
    config = {}
    
    if file.open("config.data") then
        config_string = file.read()
        file.close()
        config = query_string(config_string)
    end

    -- set defaults
    if config['notify_delay'] == nil then
        config['notify_delay'] = 30
    end
    if config['notify_repeat_count'] == nil then
        config['notify_repeat_count'] = 5
    end
    if config['notify_repeat_delay'] == nil then
        config['notify_repeat_delay'] = 60
    end
    if config['notify_text'] == nil then
        config['notify_text'] = 'Door is open'
    end


--    for key, value in pairs(config) do
--        print (key, value)
--    end

    return config
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