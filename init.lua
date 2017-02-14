TMR_ID_START = 0

print('Starting...')
tmr.alarm(TMR_ID_START, 3000, 1, function()
    config_mode = true; -- @todo determinate on gpio
    
    if config_mode then
        print('Starting config mode...')
        dofile('setup-ap.lua')
        dofile('config-server.lua')
    else
        print('Starting work mode...')
        dofile('work-mode.lua')
    end    
end)

