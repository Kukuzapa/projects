--* * * * * /usr/local/openresty/bin/resty /home/user/dev-77/module/cron_d77.lua >> /home/user/dev-77/module/cron_d77.log
local http 	 = require "resty.http"
local httpc  = http.new()
local pretty = require 'pl.pretty'

local res, err = httpc:request_uri( 'http://tci-api.gtn.ee:8081/api/v2.1/cron', { headers = { ['Authorization'] = 'Basic S3VrdXphcGE6TnRudHlqZDE=' } } )

if err then
	print( os.date('%c',os.time()) .. ': ' .. err )
	return
end

if res.body ~= '{}' then
	--print( os.date('%c',os.time()) .. ': были обработаны задания в очереди' )
	if res.status ~= '200' then
		print( os.date('%c',os.time()) .. res.status )
	else
		print( os.date('%c',os.time()) .. ': были обработаны задания в очереди' )
	end
	
	return 
end
