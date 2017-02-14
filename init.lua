TMR_ID_START = 0
TMR_ID_STEERING = 5
LED_PIN = 4 --GPIO2
CONTROL_SWITCH_PIN = 3 --GPIO0

gpio.mode(CONTROL_SWITCH_PIN, gpio.INPUT)
gpio.mode(LED_PIN, gpio.OUTPUT)

print('Starting...')

config_mode = gpio.read(CONTROL_SWITCH_PIN)

tmr.alarm(TMR_ID_STEERING, 1000, 1, function()
    if (gpio.read(CONTROL_SWITCH_PIN) ~= config_mode) then
        print('Mode changed, restart ESP')
        tmr.stop(TMR_ID_STEERING)
        tmr.stop(TMR_ID_START)
        node.restart()
    end
end)

tmr.alarm(TMR_ID_START, 3000, 1, function()
    tmr.stop(TMR_ID_START)

    gpio.write(LED_PIN, config_mode)
    
    if config_mode ~= 1 then
        print('Starting config mode...')
        dofile('setup-ap.lua')
        dofile('config-server.lua')
    else
        print('Starting work mode...')
        dofile('work-mode.lua')
    end    
end)
