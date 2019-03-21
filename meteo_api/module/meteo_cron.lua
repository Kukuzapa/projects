--Модуль отправки хттп
local http    = require 'resty.http'
--Модуль penlight, для работы с хмл, таблицам и строками
local xml     = require 'pl.xml'
local stringx = require 'pl.stringx'
local tablex  = require 'pl.tablex'
--Lua file system
--local lfs     = require 'lfs'
local pretty = require 'pl.pretty'
local redis  = require "resty.redis"

local httpc = http.new()
--Ставим таймер 30 секунд
httpc:set_timeout(30000)


local red = redis:new()
red:set_timeout(1000)
local ok, err = red:connect("unix:/tmp/redis.sock")

--Запрос к станции
local res, err = httpc:request_uri('http://10.159.0.82/xml.xml')

if err then
	--local log,r = io.open( lfs.currentdir() .. '/error.log', 'a' )
	--log:write( os.date('%c',os.time()) .. ': ' .. err .. '\n' )
	print( os.date('%c',os.time()) .. ' Запрос к метеостанции: ' .. err )

	local res, err = red:get('error')
	if type(res) == 'userdata' then
		local ok, err = red:set('error', 1 )
		local ok, err = red:set('start_error', os.date('%c',os.time()) .. ' Начало проблем' )
	else 
		local ok, err = red:set('error', res + 1 )
		--if (res + 1) == 7 then print('alert') end
	end

	return
else
	local ok, err = red:del('error')
	local ok, err = red:del('start_error')
end

--pretty.dump(res)

--Запись в базу
local function set_var( sql, verr )
	local params = {
		method = 'POST',
		body = sql
	}

	local res, err = httpc:request_uri('http://127.0.0.1:8123',params)

	if res.reason ~= 'OK' then
		print( os.date('%c',os.time()) .. ': ( ' .. sql .. ' )' .. res.reason .. ', ' .. res.body )
	end

	--[[local red = redis:new()
	red:set_timeout(1000)
	local ok, err = red:connect("unix:/tmp/redis.sock")]]

	if tablex.size( verr ) > 0 then
		print( os.date('%c',os.time()) .. ': ' .. table.concat( verr, ', ' ) )

		local res, err = red:get('error')
		if type(res) == 'userdata' then
			local ok, err = red:set('error', 1 )
			local ok, err = red:set('start_error', os.date('%c',os.time()) .. ' Начало проблем' )
		else 
			local ok, err = red:set('error', res + 1 )
			--if (res + 1) == 7 then print('alert') end
		end
	else
		local ok, err = red:del('error')
		local ok, err = red:del('start_error')
	end

	return res, err
end

--Поиск по тэгу в хмл
local function find( tbl, fin, tag )
	if tbl.tag == tag then
		if tag == 'sensor' then
			local tmp = {}
			for j,u in pairs( tbl ) do
				if type( u ) == 'table' and u.tag then
					tmp[u.tag] = u[1]
				end
			end
			table.insert( fin, tmp )
		end
		if tag == 'minmax' then
			for j,u in pairs( tbl ) do
				if type( u ) == 'table' and u.tag then
					local tmp = {}
					for i,v in pairs( u.attr ) do
						tmp[i] = v
					end
					table.insert( fin, tmp )
				end
			end
		end
		if tag == 'variable' then
			for i,v in pairs( tbl ) do
				if v.tag then
					fin[v.tag] = v[1]
				end
			end
		end
	else
		for i,v in pairs( tbl ) do
			if type( v ) == 'table' then
				find( v, fin, tag )
			end
		end
	end
end

--Парсим хмл
local prs
if res then
	prs = xml.basic_parse( res.body, false, false )
end

--Вытаскиваем данные
local tmp = {}  local minmax = {}  local variable = {}  local sensor = {}

find( prs or {}, tmp, 'sensor' )

find( prs or {}, minmax, 'minmax' )

find( prs or {}, variable, 'variable' )

--Формируем таблицу сенсор
for i,v in pairs( tmp ) do
	if v.type ~= 'io' and v.type ~= 'ping' then
		for j,u in pairs( minmax ) do
			if v.id == u.id then
				v.min = u.min
				v.max = u.max
			end
		end
		table.insert( sensor, v )
	end
end

--pretty.dump(sensor)

--Формируем инсерты
local var = ''  local val = '' local verr = {}

for i,v in pairs( sensor ) do

	--local coof = 1

	if v.type == 'pressure' then
		if v.value and v.value ~= 'ERROR' then
			var = var .. v.type .. '__value,'
			val = val .. tostring( math.ceil( (tonumber( v.value )*0.75 )*10 )/10 ) .. ","
		else
			table.insert( verr, 'sensor ' .. v.type .. '__value = ERROR' )
		end
	
		if v.min and v.min ~= 'ERROR' then	
			var = var .. v.type .. '__min,'
			val = val .. tostring( math.ceil( (tonumber( v.min )*0.75 )*10 )/10 ) .. ","
		else
			table.insert( verr, 'sensor ' .. v.type .. '__min = ERROR' )
		end

		if v.max and v.max ~= 'ERROR' then
			var = var .. v.type .. '__max,'
			val = val .. tostring( math.ceil( (tonumber( v.max )*0.75 )*10 )/10 ) .. "," 
		else
			table.insert( verr, 'sensor ' .. v.type .. '__max = ERROR' )
		end
	else
		if v.value and v.value ~= 'ERROR' then
			var = var .. v.type .. '__value,'
			val = val .. v.value .. ","
		else
			table.insert( verr, 'sensor ' .. v.type .. '__value = ERROR' )
		end
	
		if v.min and v.min ~= 'ERROR' then	
			var = var .. v.type .. '__min,'
			val = val .. v.min .. ","
		else
			if v.type ~= 'exposure_ideal' then
				table.insert( verr, 'sensor ' .. v.type .. '__min = ERROR' )
			end
		end

		if v.max and v.max ~= 'ERROR' then
			var = var .. v.type .. '__max,'
			val = val .. v.max .. "," 
		else
			if v.type ~= 'exposure_ideal' then
				table.insert( verr, 'sensor ' .. v.type .. '__max = ERROR' )
			end
		end
	end
end

var = stringx.strip( var, ',' )
val = stringx.strip( val, ',' )

if string.len( val ) > 0 then
	local sql = 'INSERT INTO meteo.sensor (' .. var .. ') VALUES (' .. val .. ')'

	--print(sql)

	local res, err = set_var( sql, verr )

	
	--pretty.dump(res)
end

local var = ''  local val = '' local verr = {}
local strngs = { 'sunrise', 'sunset', 'civstart', 'civend', 'nautstart', 'nautend', 'astrostart', 'astroend', 'daylen', 'civlen', 'nautlen', 'astrolen' }

for i,v in pairs( variable ) do
	if v ~= 'ERROR' then
		var = var .. i .. ','
		if tablex.find( strngs, i ) then
			local t = stringx.split( v, ':' )
			val = val .. "'" .. stringx.rjust( t[1], 2, '0' ) .. ':' .. stringx.rjust( t[2], 2, '0' ) .. "',"
		else
			if i == 'pressure_old' then
				val = val .. tostring( math.ceil( (tonumber( v )*0.75 )*10 )/10 ) .. ","
			else
				val = val .. v .. ","
			end
		end
	else
		table.insert( verr, 'variable ' .. i .. ' = ERROR' )
	end
end

var = stringx.strip( var, ',' )
val = stringx.strip( val, ',' )

if string.len( val ) > 0 then
	local sql = 'INSERT INTO meteo.variable (' .. var .. ') VALUES (' .. val .. ')'
	local res, err = set_var( sql, verr )
end