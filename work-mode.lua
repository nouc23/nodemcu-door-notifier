require 'config'

TMR_ID_WIFI = 1
TMR_ID_NOTIFY_START = 2
TMR_ID_NOTIFY_LOOP = 3

-- load config
print('Starting notification job')
config = load_config()

-- @todo remove
config['wifi_ssid'] = 'UPC6188466';
config['wifi_pass'] = 'BPBUWEQT';
config['notify_delay'] = 5;
config['notify_repeat_count'] = 10;
config['notify_repeat_delay'] = 10;

function connect_to_wifi () 
    print('Try to connect to', config['wifi_ssid'])
    wifi.setmode(wifi.STATION)
    wifi.sta.config(config['wifi_ssid'], config['wifi_pass'])
    return
end

function send_notification()
    print('Sending notification', config['notify_text'])

    -- https://justsend.pl:443/api/rest/bulk/send/API_KEY
--{
--  "groupId": 0,
--  "from": "door-notifier",
--  "sendDate": "2017-01-01T17:00:00+02:00",  -- date from past
--  "bulkVariant": "ECO",
--  "to": [
--    "{{MSISDNS}}",
--    "{{MSISDNS}}",
--    "{{MSISDNS}}"
--  ],
--  "message": "{{MESSAGE_TEXT}}",
--  "name": "door-notifier"
--}

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
    tmr.alarm(TMR_ID_WIFI, 1000, 1, function()
        if wifi.sta.getip()==nil then
            print(".")
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

-- wait for `notify_delay` seccond

-- begin repeat `notify_repeat_count` times

    -- wait `notify_repeat_delay` in loop

--for key, value in pairs(config) do
--    print (key, value)
--end
