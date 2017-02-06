print('Starting...')

configMode = true; -- @todo determinate on gpio

if configMode then
	print('Starting config mode...')
	dofile('setup-ap.lua')
	dofile('config-server.lua')
else
    print('Starting work mode...')
    dofile('work-mode.lua')
end
