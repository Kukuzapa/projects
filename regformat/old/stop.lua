local inspect = require 'inspect'
local stringx = require 'pl.stringx'
local lfs     = require 'lfs'

local conf    = require 'conf.conf'

local mysql   = require "resty.mysql"
local db, err = mysql:new()


--print( lfs.currentdir() )

--print( inspect( conf ) )



local ok, err, errcode, sqlstate = db:connect( conf )

if not ok then
	print( os.date('%c',os.time()) .. "failed to connect: ", err, ": ", errcode, " ", sqlstate )
	return
end

--print( os.date('%c',os.time()) .. "connected to mysql." )

--local fin = {}

local count = { ru = 0, rf = 0 }

local del_cnt = { ru = 0, rf = 0 }

local add_cnt = { ru = 0, rf = 0 } 
--local count_ru = 0

local hour = os.date( '%Y-%m-%d %H' )



local function stop_list_insert( tbl, count, hr )

	local dmn = tbl.domain
	local tld = 'RU'

	if tbl.tld == 'рф' then
		tld = 'RF'
	end

	db:query( [[INSERT INTO stop_list (domain,tld,act_date) VALUES 
		(']] .. dmn .. [[',(SELECT id FROM registrars WHERE registrar = ']] .. tld .. [['),']] .. hr .. [[');]] )

	local cnt = count + 1

	return cnt
end



--local counts = 0

for i,v in pairs( count ) do

	--выберем из БД стоп-лист
	local sel = db:query( [[SELECT * FROM stop_list WHERE tld = ( SELECT id FROM registrars WHERE registrar = ']] .. string.upper( i ) .. [[' )]] )

	count[i] = #sel

	--print( inspect( sel ) )
	--print( #sel )

	--Идем по файлу стоп-листа
	for line in io.lines( lfs.currentdir() .. '/files/' .. i .. '/StopList' ) do 

		local split  = stringx.split( line )

		--Вытаскиваем домен
		local domain = stringx.split( split[2], '.' )[1]

		local check = 0
		
		--Проходим по нашему листу и ищем совпадение с доменом
		for j,u in pairs( sel ) do
			if domain == u.domain then
				--db:query( [[UPDATE stop_list SET act_date = ']] .. hour .. [[' WHERE domain = ']] .. domain .. [[']] )
				--counts = counts + 1
				--print( counts )

				--Если нашли ставим признак
				sel[j]['check'] = 1

				--Делаем отметку
				check = 1
				break
			end
		end

		--Если отметка не поменялась, значит домен новый. Его надо добавить.
		if check == 0 then
			--print( 'no check' )

			add_cnt[i] = add_cnt[i] + 1

			db:query( [[INSERT INTO stop_list (domain,tld,act_date) VALUES 
				(']] .. domain .. [[',(SELECT id FROM registrars WHERE registrar = ']] .. string.upper( i ) .. [['),']] .. hour .. [[');]] )
		end


	end

	--Проходим еще раз по выборке и сносим к херам неотмеченные, т.е. отсутствующие в стоп-листе домены
	for j,u in pairs( sel ) do
		if not u.check then
			
			del_cnt[i] = del_cnt[i] + 1

			db:query( [[DELETE FROM stop_list WHERE domain = ']] .. u.domain .. [[';]] )

		end
	end

	--print( inspect( sel ) )
end

--print( ocount['ru'], ' ', count['rf'] )

print( '--------------------', os.date('%c',os.time() ), '---------------------------' )

for i,v in pairs( count ) do
	print( i .. ': ' .. 'add - ' .. add_cnt[i] .. ', rem - ' .. del_cnt[i] .. ', all - ' .. count[i] )
end