require 'config'

collectgarbage()

TMR_ID_WIFI = 1
TMR_ID_NOTIFY_START = 2
TMR_ID_NOTIFY_LOOP = 3
TMR_ID_LED_BLINK = 4

LED_PIN = 4 --GPIO2

gpio.mode(LED_PIN, gpio.OUTPUT)

-- load config
print('Starting notification job')
config = load_config()

-- @todo remove
config['notify_delay'] = 1


function connect_to_wifi () 
    print('Try to connect to', config['wifi_ssid'])
    wifi.setmode(wifi.STATION)
    wifi.sta.config(config['wifi_ssid'], config['wifi_pass'])
    return
end

function blink_led(time)
    gpio.write(LED_PIN, gpio.LOW)
    
    tmr.alarm(TMR_ID_LED_BLINK, time, 1, function()
        gpio.write(LED_PIN, gpio.HIGH)
        tmr.stop(TMR_ID_LED_BLINK)
    end)
    return 
end

function split(str, sep)
    local sep, fields = sep or ",", {}
    local pattern = str.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

function send_notification()
    print('Sending notification', config['notify_text'])

    blink_led(1500)

    msisdns = {}
    
    for msisdn in string.gmatch(config['notify_sms_msisdns'], "[^,]+") do
        table.insert(msisdns, msisdn)
    end

    if table.getn(msisdns) > 0 then
        url = '/api/rest/bulk/send/' .. string.gsub(config['notify_sms_apikey'] , "%s+", "")
        json = 
               '{'
                .. '"groupId": 0,'
                .. '"from": "door-notifier",'
                .. '"sendDate": "2017-01-01T17:00:00+02:00",'  -- date from past
                .. '"bulkVariant": "ECO",'
                .. '"to": ["' .. table.concat(msisdns, '","') .. '"],'
                .. '"message": "' .. config['notify_text'] .. '",'
                .. '"name": "door-notifier"'
            .. '}'


        frame = "POST " .. url .. " HTTP/1.1\r\n"
        .. "Accept: application/json\r\n"
        .. "Connection: keep-alive\r\n"
        .. "Content-Length: " .. string.len(json) .. "\r\n"
        .. "Content-Type: application/json\r\n"
        .. "Host: justsend.pl\r\n"
        .. "Origin:https://justsend.pl\r\n"
        .. "\r\n" 
        .. json
        
        print(frame)
    
        conn=net.createConnection(net.TCP, false) 
        conn:on("receive", function(conn, payload)
            print("receive", payload)
        end)
        conn:connect(443, "justsend.pl")
        conn:send(frame)

    end

end


function start_notification_loop ()
    print('Start notification loop')

    repeat_count = config['notify_repeat_count']

    send_notification()

    tmr.alarm(TMR_ID_NOTIFY_LOOP, config['notify_repeat_delay'] * 1000, 1, function()
        send_notification()

        repeat_count = repeat_count - 1

        if (repeat_count <= 1) then
            print ('Stopping notification loop')
            tmr.stop(TMR_ID_NOTIFY_LOOP)
        end       
    end)
end

function start_notification_timer ()
    print('Starting notification timer')
    
    tmr.alarm(TMR_ID_NOTIFY_START, config['notify_delay'] * 1000, 1, function()
        start_notification_loop()
       
        tmr.stop(TMR_ID_NOTIFY_START)
       
    end)
end


-- check wifi credentials and connect to wifi
if config['wifi_ssid'] ~= nil and config ['wifi_pass'] ~= nil then
    connect_to_wifi()

    -- wait for wifi connection
    tmr.alarm(TMR_ID_WIFI, 400, 1, function()
        if wifi.sta.getip()==nil then
            blink_led(50)
        else
            print("Got IP address " .. wifi.sta.getip())
            start_notification_timer (
                config['notify_delay'],
                config['notify_repeat_count'],
                config['notify_repeat_delay'],
                config['notify_text']
            )
            tmr.stop(TMR_ID_WIFI)
        end
    end)
else
    print('No wifi credentials')
end
