local http   = require 'resty.http'
local pretty = require 'pl.pretty'
local tablex = require 'pl.tablex'
local redis  = require "resty.redis"
local json   = require 'cjson'

local httpc = http.new()

--Данные для запроса инфы от опенвеазер
local APPID = 'appid=4d6945007e334c1f7ddfac00939f7bfa'
local Q     = 'q=Perm,ru'
local UNITS = 'units=metric'
local CNT   = 'cnt=40'
--Апи для прогноза
local api   = 'http://api.openweathermap.org/data/2.5/forecast'
--Запрашиваем прогноз
local res, err = httpc:request_uri( api, { query = Q .. '&' .. UNITS .. '&' .. CNT .. '&' .. APPID } )

if err then
	print( os.date('%c',os.time()) .. ' ошибка запроса прогноза погоды: ' .. err )
	return
end

if res.reason ~= 'OK' then
	local body = json.decode( res.body )
	print( os.date('%c',os.time()) .. ' ошибка запроса прогноза погоды: ' .. res.reason .. ', ' .. body.cod .. ', ' .. body.message )
	return
end

--Берем полученное тело ответа
local body = json.decode( res.body )
--И разбираем его в таблицу фин
local fin = {}

for i,v in pairs( body.list ) do
	local tmp = {}
	tmp.td = v.dt
	tmp.temperature = v.main.temp
	tmp.pressure = tostring( math.ceil( (tonumber( v.main.pressure )*0.75 )*10 )/10 )
	tmp.humidity = v.main.humidity
	tmp.weather_id = v.weather[1].id
	tmp.weather_icon = v.weather[1].icon
	table.insert( fin, tmp )
end

--Апи для текущей погоды
local api = 'http://api.openweathermap.org/data/2.5/weather'
--Запрос текущей погоды
local res, err = httpc:request_uri( api, { query = Q .. '&' .. UNITS .. '&' .. APPID } )

if err then
	print( os.date('%c',os.time()) .. ' ошибка запроса текущей погоды: ' .. err )
	return
end

if res.reason ~= 'OK' then
	local body = json.decode( res.body )
	print( os.date('%c',os.time()) .. ' ошибка запроса текущей погоды: ' .. res.reason .. ', ' .. body.cod .. ', ' .. body.message )
	return
end

--Берем полученное тело ответа
local body = json.decode( res.body )
--И разбираем его в таблицу нау
local now = {}
now.td = body.dt
now.temperature = body.main.temp
now.pressure = tostring( math.ceil( (tonumber( body.main.pressure )*0.75 )*10 )/10 )
now.humidity = body.main.humidity
now.weather_id = body.weather[1].id
now.weather_icon = body.weather[1].icon

--Запись данных в БД Редис начинается отсюда
local red = redis:new()

red:set_timeout(1000)

--Связь с редисом
--local ok, err = red:connect("127.0.0.1", 6379)

local ok, err = red:connect("unix:/tmp/redis.sock")

if not ok then
	print( os.date('%c',os.time()) .. ' ошибка соедение с редисом: ' .. err )
	--ngx.say("failed to connect: ", err)
	return
--else
	--print('все здорово')
end

--Запись в редис прогноза погоды
for i,v in pairs( fin ) do
	
	local ok, err = red:set(i, json.encode(v))
	
	if not ok then
		print( os.date('%c',os.time()) .. ' ошибка записи прогноза погоды: ' .. err )
		return
	end
end

--Пишем в редис текущюю погоду
local ok, err = red:set('now', json.encode(now))

if not ok then
	print( os.date('%c',os.time()) .. ' ошибка записи текущей погоды: ' .. err )
	return
end