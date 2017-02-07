print('Starting...')

config_mode = true; -- @todo determinate on gpio

if config_mode then
	print('Starting config mode...')
	dofile('setup-ap.lua')
	dofile('config-server.lua')
else
    print('Starting work mode...')
    dofile('work-mode.lua')
end