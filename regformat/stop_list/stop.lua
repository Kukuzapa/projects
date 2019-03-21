local inspect = require 'inspect'
local stringx = require 'pl.stringx'

local lfs = require 'lfs'

local conf = require 'files.conf'

print( lfs.currentdir() )

print( inspect( conf ) )

local mysql = require "resty.mysql"
local db, err = mysql:new()

local ok, err, errcode, sqlstate = db:connect( conf )

if not ok then
    --ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
    print( os.date('%c',os.time()) .. "failed to connect: ", err, ": ", errcode, " ", sqlstate )
    return
end

print( os.date('%c',os.time()) .. "connected to mysql." )

--local fin = {}

local count_rf = 0
local count_ru = 0

local function stop_list_insert( tbl, count )

	local dmn = tbl.domain
	local tld = 'RU'

	if tbl.tld == 'рф' then
		tld = 'RF'
	end

	db:query( [[INSERT INTO stop_list (domain,tld,act_date) VALUES 
		(']] .. dmn .. [[',(SELECT id FROM registrars WHERE registrar = ']] .. tld .. [['),CURDATE());]] )

	local cnt = count + 1

	return cnt
end

for line in io.lines( lfs.currentdir() .. '/files/StopList_rf' ) do 
	--print( line )

	local split = stringx.split( line )

	--count_rf = stop_list_insert( { domain = stringx.split( split[2], '.' )[1], tld = stringx.split( split[2], '.' )[2] }, count_rf )
end

--print( inspect( fin ) )

--local fin = {}

for line in io.lines( lfs.currentdir() .. '/files/StopList_ru' ) do 
	--print( line )

	local split = stringx.split( line )

	--count_ru = stop_list_insert( { domain = stringx.split( split[2], '.' )[1], tld = stringx.split( split[2], '.' )[2] }, count_ru )
end

--print( inspect( fin ) )

print( count_ru, ' ', count_rf )

--local sel = db:query( [[SELECT * FROM domains;]] )

--print( inspect( sel ) )

local https  = require "ssl.https"
local ltn12  = require "ltn12"
local ssl    = require "ssl"
local socket = require "socket"
local http   = require "socket.http"

local response_body = {}

local res, code, response_headers = https.request{
  		url         = 'https://getdata.tcinet.ru',
  		key         = lfs.currentdir() .. '/files/ru/clikey (1).pem',
  		certificate = lfs.currentdir() .. '/files/ru/clicert (1).pem',
  		method      = "GET";
  		--protocol    = "any",
  		--options     = "all",
  		--verify      = "none",
  		
  		--headers     = {
  			--["Content-Length"] = string.len(request_body);
  			--["Content-Type"]   = "text/xml; charset=UTF-8",
  			--["User-Agent"]     = "EPP Client /1.0",
  			--["Host"]           = body.host .. ':' .. body.port,
  			--["Cookie"]         = sesid,
 		--};
 		--source = ltn12.source.string(request_body);
 		sink   = ltn12.sink.table(response_body);
 	}

print( inspect( res ) )
print( code )
print( inspect( response_headers ) )

print( inspect( response_body ) )
