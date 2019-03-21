local lapis   = require 'lapis'
local http    = require 'resty.http'
--Модуль penlight, для работы с хмл и строками
local pretty  = require 'pl.pretty'
local stringx = require 'pl.stringx'
local tablex  = require 'pl.tablex'
local json    = require 'cjson'
local redis   = require "resty.redis"

local httpc = http.new()

--Словарь
local DICTIONARY = {
	sensor = {	
		temperature          = 'температура',
		temperature_apparent = 'ощущаемая температура',
		wind_speed           = 'скорость ветра',
		wind_direction       = 'направление ветра',
		wind_gust            = 'порывы ветра',
		precipitation        = 'атмосферные осадки',
		pressure             = 'давление',
		dew_point            = 'точка росы',
		humidity             = 'влажность',
		exposure             = 'солнечная радиация',
		exposure_ideal       = 'идеальная солнечная радиация'
	},
	variable = {
		sunrise         = 'Восход',
		sunset          = 'закат солнца',
		agl             = 'Высота облачного покрова',
		astroend        = 'конец астрономических сумерек',
		astrolen        = 'астрономические сумерки',
		astrostart      = 'начало астрономических сумерек',
		bio             = 'биометеорологический прогноз',
		civend          = 'конец гражданских сумерек',
		civlen          = 'гражданская длина сумерек',
		civstart        = 'начало гражданских сумерек',
		daylen          = 'дневная длина',
		fog             = 'туманность',
		isday           = 'Время суток',
		moonphase       = 'Фаза луны',
		nautend         = 'конец морских сумерек',
		nautlen         = 'длина морской сумерек',
		nautstart       = 'начало морских сумерек',
		pressure_old    = 'Значение давление 6 часов назад',
		temperature_avg = 'Средняя температура'
	},
	stat = {
		stat_wind_speed = 'Средняя скорость ветра за 30 минут',
		stat_wind_gust  = 'Средняя скорость ветра в порывах за 30 минут',
		stat_wind_dir   = 'Преимущественное направление ветра за 30 минут'
	}
}

local WIND_DIR = {
	[0] = 'Север',
	[45] = 'Северо-восток',
	[90] = 'Восток',
	[135] = 'Юго-восток',
	[180] = 'Юг',
	[225] = 'Юго-запад',
	[270] = 'Запад',
	[315] = 'Северо-запад'
}

--Функция отправляющая запросы к БД
local function select_request( sql )
	local params = {
		method = 'POST',
		body = sql
	}
	--Запрос к клик-хаус
	local res, err = httpc:request_uri('http://127.0.0.1:8123',params)

	if not err then
		if res.reason ~= 'OK' then
			err = { err = res.reason .. ': ' .. res.body }
		else
			res = json.decode( res.body ).data
		end
	end

	return res, err
end

--Инициализация ляписа
local app = lapis.Application()
app:enable("etlua")
app.layout = require "views.layout"

--Рендер шаблона при входе на сайт
--app:get("/", function()
--	return { render = 'layout' }
--end)

--Отработка пути сенсор
app:get("/sensor", function()
	
	local fin = {}

	local sql = [[SELECT *
				FROM meteo.sensor
				WHERE dateValue > yesterday()
				ORDER BY dateValue DESC
				LIMIT 1
				FORMAT JSON]]

	local res, err = select_request( sql )

	if err then 
		fin = err
	else
		local tmp = res[1]
		for i,v in pairs( tmp ) do
			local t = stringx.split( i, '__' )
			if #t == 2 then
				if not fin[t[1]] then
					fin[t[1]] = {}
					fin[t[1]].name = DICTIONARY.sensor[t[1]]
				end
				fin[t[1]][t[2]] = v
				if t[1] == 'wind_direction' then
					fin[t[1]]['dir' .. t[2]] = WIND_DIR[v]
				end
			else
				fin[i] = {}
				fin[i].value = v
			end
		end
	end

	return { json = fin }
end)

--Отработка переменных
app:get("/variable", function()
	
	local fin = {}

	local sql = [[SELECT *
				FROM meteo.variable
				WHERE dateValue > yesterday()
				ORDER BY dateValue DESC
				LIMIT 1
				FORMAT JSON]]

	local res, err = select_request( sql )

	if err then 
		fin = err
	else
		for i,v in pairs( res[1] ) do
			fin[i] = {}
			fin[i].name = DICTIONARY.variable[i]
			fin[i].value = v
		end
	end

	return { json = fin }
end)

--Обработка запроса архива
app:get("/archive", function( self )

	local fin = self.req.params_get

	if tablex.size( fin ) > 0 then
		local date = tablex.copy( fin )

		local sql = [[SELECT dateValue,temperature__value,temperature_apparent__value,dew_point__value,pressure__value,humidity__value,precipitation__value,exposure__value,wind_speed__value
					FROM meteo.sensor 
					WHERE dateValue < '%s %s:%s:00'
					ORDER BY dateValue DESC
					LIMIT 1 
					FORMAT JSON]]
		sql = string.format( sql, date.date, date.hours, date.minutes )

		local res, err = select_request( sql )

		if err then 
			fin = err
		else
			if res[1] then
				for i,v in pairs( res[1] ) do
					local t = stringx.split( i, '__' )
					if #t == 2 then
						if not fin[t[1]] then
							fin[t[1]] = {}
							fin[t[1]].name = DICTIONARY.sensor[t[1]]
						end
						fin[t[1]][t[2]] = v
					else
						fin[i] = {}
						fin[i].value = v
					end
				end
			else
				fin.err = 'Невозможно получить данные за эту дату'
			end
		end

		sql = [[SELECT 
				avg(wind_speed__value) AS stat_wind_speed, 
				avg(wind_gust__value) AS stat_wind_gust, 
				topK(1)(wind_direction__value)[1] AS stat_wind_dir
				FROM meteo.sensor 
				WHERE dateValue IN 
				(
					SELECT dateValue
					FROM meteo.variable 
					WHERE dateValue < '%s %s:%s:00'
					ORDER BY dateValue DESC
					LIMIT 30
				)
				FORMAT JSON]]
		sql = string.format( sql, date.date, date.hours, date.minutes )

		if not fin.err then
			local res, err = select_request( sql )

			if err then
				fin = err
			else
				if res[1] then
					for i,v in pairs( res[1] ) do
						fin[i] = {}
						fin[i].name = DICTIONARY.stat[i]
						if i == 'stat_wind_dir' then
							fin[i]['dir'] = WIND_DIR[v]
							fin[i].value = v
						else
							fin[i].value = math.ceil( v*10 )/10
						end
					end
				else
					fin.err = 'Невозможно получить данные за эту дату'
				end
			end
		end
	end
	
	return { json = fin }
end)

--Обработка графиков
app:get("/graphs", function(self)
	
	local fin = self.req.params_get
	local grph = {}

	if tablex.size( fin ) > 0 then
		local sql = [[SELECT dateValue,%s
					FROM meteo.%s 
					WHERE dateValue > %s
					ORDER BY dateValue ASC
					FORMAT JSON]]

		local sensor = {}
		
		sensor[1] = fin.sensor1
		sensor[2] = fin.sensor2 or 'nothing'

		local period = fin.period

		local step = tonumber( fin.step )

		if period == '0' then
			period = 'toStartOfDay(now())'
		else
			period = string.format( '(now() - %s)', tostring( tonumber(period)*60*60) )
		end

		for i,s in pairs( sensor ) do
			fin = {}

			local db_table, column
			if rawget( DICTIONARY.sensor, s ) then
				db_table = 'sensor'
				column = s .. '__value'
			else
				db_table = 'variable'
				column = s
			end

			local req = string.format( sql, column, db_table, period )

			local res, err = select_request( req )

			if s == 'precipitation' then
				local count = 0
				local prtme = res[#res].dateValue
				local prval = 0
				for i=#res,1,-1 do
					prval = prval + res[i][column]
					count = count + 1
					if count == step then
						table.insert( fin, 1, { prtme, prval } )
						prval = 0
						count = 0
						if res[i-1] then
							prtme = res[i-1].dateValue
						end
					end
				end
			else
				for i=#res,1,-step do
					table.insert( fin, 1, { res[i].dateValue, res[i][column] } )
				end
			end

			table.insert( grph, fin )
		end

		--ГЛЮК
		if tablex.size( grph[2] ) > 0 then
			for i,v in pairs( grph[2] ) do
				table.insert( grph[1][i], v[2] )
			end
		end
		grph[2] = nil
		grph = tablex.copy( grph[1] )
	end

	return { json = grph }
end)

--Прогноз пагоды
app:get("/forecast", function()

	local fin = {}

	local red = redis:new()
	
	red:set_timeout(1000)

	--local ok, err = red:connect("127.0.0.1", 6379)
	local ok, err = red:connect("unix:/tmp/redis.sock")

	if not ok then
    	--ngx.say("Проблема со связью с редисом: ", err)
    	return { json = { err = 'Проблема со связью с редисом: ' .. err } }
	end

	for i=1,5 do
	--for i=1,40 do
		local res, err = red:get(i)
		if not res then
    		--ngx.say("Невозможно получить обновление погодыы: ", err)
    		return { json = { err = 'Невозможно получить обновление погодыы: ' .. err } }
		end
		if type( res ) ~= 'userdata' then
			table.insert(fin, json.decode(res))
		end
	end

	for i,v in pairs( fin ) do
		v.td = os.date('%d-%m-%Y %X',v.td )
	end

	return { json = fin }
end)

app:get("/weather", function()

	local fin = {}

	local red = redis:new()
	
	red:set_timeout(1000)

	--local ok, err = red:connect("127.0.0.1", 6379)
	local ok, err = red:connect("unix:/tmp/redis.sock")

	if not ok then
    	--ngx.say("Проблема со связью с редисом: ", err)
    	--return
    	return { json = { err = 'Проблема со связью с редисом: ' .. err } }
	end

	local res, err = red:get('now')
	if not res then
    	--ngx.say("Невозможно получить обновление погодыы: ", err)
    	--return
    	return { json = { err = 'Невозможно получить обновление погодыы: ' .. err } }
	end
		
	fin = json.decode( res )

	fin.td = os.date('%d-%m-%Y %X',fin.td )

	return { json = fin }
end)

app:get("/status", function()

	local fin = {}

	local red = redis:new()
	
	red:set_timeout(1000)

	--local ok, err = red:connect("127.0.0.1", 6379)
	local ok, err = red:connect("unix:/tmp/redis.sock")

	if not ok then
    	--ngx.say("Проблема со связью с редисом: ", err)
    	--return
    	return { json = { err = 'Проблема со связью с редисом: ' .. err } }
	end

	local count, err = red:get('error')
	local start, err = red:get('start_error')

	if type(count) == 'userdata' then
		return { json = { message = 'Станция работает', status = 'ok' } }
	else
		return { json = { start = start, count = 'Количество ошибок: ' .. count, status = 'error' } }
	end
end)


app:match("/(*)", function()
	return { render = 'layout' }
end)

return app
