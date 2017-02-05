print('Starting...')

configMode = true; -- @todo determinate on gpio

if configMode then
	print('Starting config mode...')
	dofile('configMode.lua')
else
    print('Starting work mode...')
    dofile('workMode.lua')
end
