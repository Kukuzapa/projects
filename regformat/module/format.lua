local format = {}

--Обработка паникода
local idn    = require 'module.punycode.idn'

--Работа с таблицами, библиотека penlight
local tablex  = require 'pl.tablex'
local stringx = require 'pl.stringx'

local utf8    = require 'lua-utf8'

--Модуль ляписа
local db     = require("lapis.db")
local util   = require("lapis.util")

--Формирование дочерней таблицы
function format.make_child_table( name, text, attr, kids )

	local st = { name = name, text = text }

	if attr then
		st.attr = {}
		for i,v in pairs(attr) do
			st.attr[i] = v
		end
	end

	if kids then st.kids = {} end

	return st
end

--Формирование запроса
function format.epp_template( command, object, transfer_attr )
	local dict = { contact = 'ripn-contact-1.0', host = 'ripn-host-1.0', registrar = 'ripn-registrar-1.0', domain = 'ripn-domain-1.0' }

	--Заранее определим аттрибуты xml
	local command_attr, transf_attr
	if command == 'transfer' then
		command_attr = {
			['xmlns:'..object]     = 'http://www.ripn.net/epp/ripn-domain-1.1',
			['xsi:schemaLocation'] = 'http://www.ripn.net/epp/ripn-domain-1.1 ripn-domain-1.1.xsd'
		}
		transf_attr = { op = transfer_attr }
	else
		command_attr = {
			['xmlns:'..object]     = 'http://www.ripn.net/epp/' .. dict[object],
			['xsi:schemaLocation'] = 'http://www.ripn.net/epp/' .. dict[object] .. ' ' .. dict[object] .. '.xsd'
		}
	end

	--Данная таблица будет использована для добавления пользовательских данных
	local my_kid = format.make_child_table( object .. ':' .. command, nil, command_attr )

	local main_attr = {
		xmlns                  = 'http://www.ripn.net/epp/ripn-epp-1.0',
		['xmlns:xsi']          = 'http://www.w3.org/2001/XMLSchema-instance',
		['xsi:schemaLocation'] = 'http://www.ripn.net/epp/ripn-epp-1.0 ripn-epp-1.0.xsd'
	}
	
	local epp = format.make_child_table( 'epp', nil, main_attr, 'Children are the flowers of life' )

	local obj_command = format.make_child_table( 'command', nil, nil, 'Children are the flowers of life' )
	
	local command_kid = format.make_child_table( command, nil, transf_attr, 'Children are the flowers of life' )
	table.insert( command_kid.kids, my_kid )
	table.insert( obj_command.kids, command_kid )
	table.insert( obj_command.kids, format.make_child_table( 'clTRID' ) )

	table.insert( epp.kids, obj_command )

	return epp, my_kid
end

--Запрос/подтверждение сообщений
function format.poll( command, msgid )

	local poll_attr = {
		op    = command, 
		msgID = msgid
	}

	local main_attr = {
		xmlns                  = 'http://www.ripn.net/epp/ripn-epp-1.0',
		['xmlns:xsi']          = 'http://www.w3.org/2001/XMLSchema-instance',
		['xsi:schemaLocation'] = 'http://www.ripn.net/epp/ripn-epp-1.0 ripn-epp-1.0.xsd'
	}

	local epp = format.make_child_table( 'epp', nil, main_attr, 'Children are the flowers of life' )

	local command = format.make_child_table( 'command', nil, nil, 'Children are the flowers of life' )
	table.insert( command.kids, format.make_child_table( 'poll', nil, poll_attr ) )
	table.insert( command.kids, format.make_child_table( 'clTRID' ) )

	table.insert( epp.kids, command )

	return epp
end

--Формирование запроса stat
function format.stat()

	local main_attr = {
		xmlns                  = 'http://www.ripn.net/epp/ripn-epp-1.0',
		['xmlns:xsi']          = 'http://www.w3.org/2001/XMLSchema-instance',
		['xsi:schemaLocation'] = 'http://www.ripn.net/epp/ripn-epp-1.0 ripn-epp-1.0.xsd'
	}

	local command_attr = {
		['xmlns:stat'] = 'http://www.tcinet.ru/epp/tci-stat-1.0',
		['xsi:schemaLocation']='http://www.tcinet.ru/epp/tci-stat-1.0 tci-stat1.0.xsd'
	}

	local epp = format.make_child_table( 'epp', nil, main_attr, 'Children are the flowers of life' )

	local command = format.make_child_table( 'command', nil, nil, 'Children are the flowers of life' )

	local info = format.make_child_table( 'info', nil, nil, 'Children are the flowers of life' )

	local my_kid = format.make_child_table( 'stat:info', nil, command_attr )

	table.insert( info.kids, my_kid )
	table.insert( command.kids, info )
	table.insert( command.kids, format.make_child_table( 'clTRID' ) )

	table.insert( epp.kids, command )
	
	return epp, my_kid
	-- body
end

--Формирования запроса limits
function format.limits()

	local main_attr = {
		xmlns                  = 'http://www.ripn.net/epp/ripn-epp-1.0',
		['xmlns:xsi']          = 'http://www.w3.org/2001/XMLSchema-instance',
		['xsi:schemaLocation'] = 'http://www.ripn.net/epp/ripn-epp-1.0 ripn-epp-1.0.xsd'
	}

	local command_attr = {
		['xmlns:limits'] = 'http://www.tcinet.ru/epp/tci-limits-1.0',
		['xsi:schemaLocation'] = 'http://www.tcinet.ru/epp/tci-limits-1.0 tci-limits1.0.xsd'
	}

	local epp = format.make_child_table( 'epp', nil, main_attr, 'Children are the flowers of life' )

	local command = format.make_child_table( 'command', nil, nil, 'Children are the flowers of life' )

	local info = format.make_child_table( 'info', nil, nil, 'Children are the flowers of life' )

	local my_kid = format.make_child_table( 'limits:info', nil, command_attr )

	table.insert( info.kids, my_kid )
	table.insert( command.kids, info )
	table.insert( command.kids, format.make_child_table( 'clTRID' ) )

	table.insert( epp.kids, command )
	
	return epp
end

--Формирование запроса биллинга
function format.billing()

	local main_attr = {
		xmlns = 'http://www.ripn.net/epp/ripn-epp-1.0',
	}

	local command_attr = {
		['xmlns:billing'] = 'http://www.tcinet.ru/epp/tci-billing-1.0'
	}

	local epp = format.make_child_table( 'epp', nil, main_attr, 'Children are the flowers of life' )

	local command = format.make_child_table( 'command', nil, nil, 'Children are the flowers of life' )

	local info = format.make_child_table( 'info', nil, nil, 'Children are the flowers of life' )

	local my_kid = format.make_child_table( 'billing:info', nil, command_attr )

	table.insert( info.kids, my_kid )
	table.insert( command.kids, info )
	table.insert( command.kids, format.make_child_table( 'clTRID' ) )

	table.insert( epp.kids, command )
	
	return epp, my_kid
end

--добавляет в таблицу данные, которые в xml будут выглядеть как <object:str>value</object:str>. Ест как строки так и таблицы
function format.set_string( self, obj, str, value, del )
	
	local tbl = tablex.deepcopy( self )
	local name = obj .. ':' .. str

	if value then
		if type(value) == 'table' then
			--ngx.say(str,' ',#value)
			if #value == 0 then
				table.insert( tbl, format.make_child_table( name ) )
			end
			for _,v in pairs( value ) do
				table.insert( tbl, format.make_child_table( name, v ) )
			end
		else
			table.insert( tbl, format.make_child_table( name, value ) )
		end
	end

	return tbl
end

--добавляет ip, <object:addr ip=v4>ip</object:addr>
function format.set_ip( self, value, obj )
	local tbl = tablex.deepcopy( self )
	if value and type(value) ~= 'boolean' then
		for _,v in pairs( value ) do

			local ver = 'v6'
			
			local chunks = {v:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")}
  			if #chunks == 4 then ver = 'v4' end

			table.insert( tbl, format.make_child_table( obj .. ':addr' , v, { ['ip'] = ver } ) )
		end
	end
	return tbl
end

--Добавляет статусы.
function format.set_status( self, obj, value )
	local tbl = tablex.deepcopy( self )
	if value then
		for _,v in pairs( value ) do
			table.insert( tbl, format.make_child_table( obj .. ':status', nil, { ['s'] = v } ) )
		end
	end
	return tbl
end

--Добавляет почтовые данные.
function format.set_postal_info( self, obj, str, value, type, del )
	local tbl = tablex.deepcopy( self )
	
	if value then
		
		local st = format.make_child_table( obj .. ':' .. str, nil, nil, 'Children are the flowers of life' )
		
		--В зависимости от типа контакта выбирает необходимое поле
		local ctype = { person = 'name', organization = 'org' }
		
		if rawget( value, ctype[type] ) then
			table.insert( st.kids, format.make_child_table( obj .. ':' .. ctype[type], rawget( value, ctype[type] ) ) )
		end
		
		if value.address then
			if #value.address == 0 then
				table.insert( st.kids, format.make_child_table( obj .. ':address' ) )
			end
			for _,v in pairs( value.address ) do
				table.insert( st.kids, format.make_child_table( obj .. ':address', v ) )
			end
		end
		
		table.insert( tbl, st )
	end
	return tbl
end

--Меняет признак verified
function format.set_ver( self, obj, value )
	local tbl = tablex.deepcopy( self )
	if value then
		table.insert( tbl, format.make_child_table( obj .. ':' .. value ) )
	end
	return tbl
end

--Добавляет authinfo
function format.set_auth( self, obj, value )
	local tbl = tablex.deepcopy( self )
	if value then
		local auth = format.make_child_table( obj .. ':authInfo', nil, nil, 'Children are the flowers of life' )
		table.insert( auth.kids, format.make_child_table( obj .. ':pw', value ) )
		table.insert( tbl, auth )
	end
	return tbl
end

--Вспомогательная ф-ия. Ищет в таблице tbl все подтаблицы где индекс name = val и добавляет их в res
function format.find( tbl, val, res )
	if tbl.name == val then
		table.insert( res, tbl )
	else
		if tbl.kids then
			for _,v in pairs( tbl.kids ) do
				format.find( v, val, res )
			end
		end
	end
end

--Ищет результат выполнения команды, возвращает коды и т.п. Возвращает кол-во непринятых сообщений реестра.
function format.response( tbl, fin, reg )
	local find = {}
	format.find( tbl, 'result', find )

	--ngx.say( 'response' .. reg )

	if #find > 0 then
		fin.result = {}
		for _,v in pairs( find ) do
			local tmp ={}
			tmp.code = v.attr.code
			for _,u in pairs( v.kids ) do
				if u.kids then 
					for _,z in pairs( u.kids ) do
						tmp[z.name] = z.text
					end
				else
					tmp[u.name] = u.text
				end
			end
			table.insert( fin.result, tmp )
			tmp = {}
		end
	end

	find = {}
	format.find( tbl, 'msgQ', find )
	if #find >0 then
		fin.message      = {}
		fin.message.msgQ = find[1].attr.count
		fin.message.id   = find[1].attr.id
		local select_poll_count = db.query( 'SELECT * FROM temp_poll_count WHERE count = "' .. fin.message.id .. '" AND reg = "' .. reg .. '"' )
		if #select_poll_count == 0 then
			db.query( 'INSERT INTO temp_poll_count ( count, reg, date ) VALUE ( "' .. fin.message.id .. '", "' .. reg .. '", NOW() )' )
		end
	end	
end

--Обработка сообщений
function format.get_message( tbl )
	find = {}
	format.find( tbl, 'msgQ', find )
	
	local fin
	
	if #find >0 then
		fin = {}

		fin.id = find[1].attr.id

		for i,v in pairs(find[1].kids) do
			fin[v.name] = v.text
		end
	end

	return fin
end

--Проверяет наличие и создает подтаблицу
--function format.try_some_data( tbl, fin, obj, str )
--	local find = {}
--	format.find( tbl, str, find )
--	
--	if #find > 0 then
--		fin[obj] = {}
--	end
--end

--Возвращвет строку
function format.get_string( tbl, str, fin )
	local find = {}
	format.find( tbl, str, find )

	if #find > 0 then
		fin[str] = find[1].text
	end
end

--Возвращает массив строк
function format.get_arrays( tbl, str, fin )
	local find = {}
	format.find( tbl, str, find )

	if #find > 0 then
		fin[str] = {}
		for _,v in pairs( find ) do
			table.insert( fin[str], v.text )
		end
	end
end

--Возвращает authinfo
function format.get_authInfo( tbl, fin )
	local find = {}
	format.find( tbl, 'pw', find )

	if #find > 0 then
		fin.authInfo = find[1].text
	end
end

--Устанавливает hostObj для доменов
function format.set_domain_hostObj( self, value )
	local tbl = tablex.deepcopy( self )
	if value and #value > 0 then
		local ns = format.make_child_table( 'domain:ns', nil, nil, 'Children are the flowers of life' )
		for _,v in pairs( value ) do
			table.insert( ns.kids, format.make_child_table( 'domain:hostObj', idn.encode( v ) ) )
		end
		table.insert( tbl, ns )
	end
	return tbl
end

--Возвращает hostObj для доменов
function format.get_domain_hostObj( tbl, fin )
	local find = {}
	format.find( tbl, 'hostObj', find )

	if #find > 0 then
		fin.hostObj = {}
		for _,v in pairs( find ) do
			table.insert( fin.hostObj, idn.decode( v.text ) )
		end
	end
end

--Возвращает статусы
function format.get_status( tbl, fin )
	local find = {}
	format.find(tbl, 'status', find)

	if #find > 0 then
		fin.status = {}
		for _,v in pairs( find ) do
			table.insert( fin.status, v.attr.s )
		end
	end
end

--Возвращает атрибут занятости имени или ид
function format.get_check( tbl, fin, str )
	local find = {}
	format.find( tbl, str, find )

	for _,v in pairs( find ) do
		fin[idn.decode( v.text )] = v.attr.avail
	end
end

--Возвращает ящики регистратора
function format.get_registrar_email( tbl, fin )
	local find = {}
	format.find( tbl, 'email', find )

	if #find > 0 then
		fin.email = {}
		for _,v in pairs( find ) do
			fin.email[v.attr.type] = v.text
		end
	end
end

--Возвращает ip доменов и хостов
function format.get_ip( tbl, fin )
	local find = {}
	format.find( tbl, 'addr', find )

	if #find > 0 then
		fin.v4 = {}
		fin.v6 = {}
		for _,v in pairs( find ) do
			table.insert( fin[v.attr.ip] , v.text )
		end
	end
end

--Возвращает почтовые адреса
function format.get_postal( tbl, str, fin )
	local find = {}
	format.find( tbl, str, find )

	if #find > 0 then
		fin[str] = {}
		for i,v in pairs( find ) do
			
			local sfind = {}
			
			format.find( v, v.kids[1].name, sfind )
			
			if #sfind >0 then
				fin[str][v.kids[1].name] = sfind[1].text
			end
			
			local sfind = {}
			
			format.find( v, 'address', sfind )
			
			if #sfind >0 then
				fin[str]['address'] = {}
				if #sfind == 1 then
					table.insert( fin[str]['address'], sfind[1].text )
				else 
					for _,u in pairs( sfind ) do
						table.insert( fin[str]['address'], u.text )
					end
				end
			end
		end
	end
end

--Возвращает признак verified
function format.get_verified( tbl, fin )
	local find = {}
	
	format.find( tbl, 'unverified', find )
	format.find( tbl, 'verified', find )

	if #find > 0 then
		fin.verified = find[1].name
	end
end

--Возвращает тип контакта
function format.get_contact_type( tbl, fin )
	local find = {}
	
	format.find( tbl, 'person', find )
	format.find( tbl, 'organization', find )

	if #find > 0 then
		fin.type = find[1].name
	end
end

--Возвращает имя домена/хоста с пуникодом
function format.get_objects_name_id( tbl, obj, fin )
	local templ = { contact = 'id', host = 'name', domain  = 'name', registrar = 'id' }

	local find = {}
	format.find( tbl, templ[obj], find )

	if #find > 0 then
		fin[templ[obj]] = idn.decode( find[1].text )
	end
end

--for similar_commands.lua Устанавливает имена и ид объектоа с паникодом
function format.set_objects_name_id( self, obj, value )
	local tbl = tablex.deepcopy( self )
	
	if value then

		local templ = { contact = 'id', host = 'name', domain  = 'name', registrar = 'id' }
		
		if obj == 'contact' then

			if type( value ) == 'table' then
				for _,v in pairs( value ) do
					table.insert( tbl, format.make_child_table( obj .. ':' .. templ[obj] , v ) )
				end
			else
				table.insert( tbl, format.make_child_table( obj .. ':' .. templ[obj] , value ) )
			end
		else
		
			if type( value ) == 'table' then
				for _,v in pairs( value ) do
					table.insert( tbl, format.make_child_table( obj .. ':' .. templ[obj] , idn.encode( v ) ) )
				end
			else
				table.insert( tbl, format.make_child_table( obj .. ':' .. templ[obj] , idn.encode( value ) ) )
			end
		end
		
	end
	return tbl
end

--Формирование команды логин
function format.login( tld, current_password )
	
	local clid = 'REGFORMAT-' .. tld --Формирование идентификатора регистратора

	--Идентификатор регистратора
	local client_id = format.make_child_table( 'clID', clid )

	--Пароль регистратора
	local client_password = format.make_child_table( 'pw', current_password )

	--Оно должно быть
	local svcs = format.make_child_table( 'svcs', nil, nil, 'Children are the flowers of life' )
	local objURI = {
		'http://www.ripn.net/epp/ripn-epp-1.0',
		'http://www.ripn.net/epp/ripn-eppcom-1.0',
		'http://www.ripn.net/epp/ripn-contact-1.0',
		'http://www.ripn.net/epp/ripn-domain-1.0',
		'http://www.ripn.net/epp/ripn-domain-1.1',
		'http://www.ripn.net/epp/ripn-host-1.0',
		'http://www.ripn.net/epp/ripn-registrar-1.0'
	}
	
	local svcExtension = format.make_child_table( 'svcExtension', nil, nil, 'Children are the flowers of life' )
	table.insert( svcExtension.kids , format.make_child_table( 'extURI', 'urn:ietf:params:xml:ns:secDNS-1.1' ) )
	table.insert( svcExtension.kids , format.make_child_table( 'extURI', 'http://www.tcinet.ru/epp/tci-promo-ext-1.0' ) )

	for _,v in pairs( objURI ) do
		table.insert( svcs.kids , format.make_child_table( 'objURI', v ) )
	end
	table.insert( svcs.kids , svcExtension )

	--Оно должно быть, можно выбрать язык ответа
	local options = format.make_child_table( 'options', nil, nil, 'Children are the flowers of life' )
	table.insert( options.kids, format.make_child_table( 'version', '1.0' ) )
	table.insert( options.kids, format.make_child_table( 'lang',    'ru' ) )

	--формируем таблицу данных пользователя
	local login = format.make_child_table( 'login', nil, nil, 'Children are the flowers of life' )

	login.kids = { client_id, client_password, options, svcs }
	
	--Полная таблица команды
	local main_attr = {
		xmlns                  = 'http://www.ripn.net/epp/ripn-epp-1.0',
		['xmlns:xsi']          = 'http://www.w3.org/2001/XMLSchema-instance',
		['xsi:schemaLocation'] = 'http://www.ripn.net/epp/ripn-epp-1.0 ripn-epp-1.0.xsd'
	}
	local epp = format.make_child_table( 'epp', nil, main_attr, 'Children are the flowers of life' )

	local command = format.make_child_table( 'command', nil, nil, 'Children are the flowers of life' )

	table.insert( command.kids, login )
	table.insert( command.kids, format.make_child_table( 'clTRID', 'connect' ) )

	table.insert( epp.kids, command )

	return epp
end


--------------------------------------------------------------------------------------------------------------------------------------------
--Формирование строки для записи в БД
function format.set_string_into_db( value )
	
	local st = 'NULL'
	
	if value then
		if type(value) == 'table' then
			if #value > 0 then
				for i,v in pairs( value ) do
					value[i] = stringx.replace( v, '"', "'" )
				end
				st = '"' .. stringx.join(';', value) .. '"'
			end
		else
			value = stringx.replace( value, '"', "'" )
			st = '"' .. value .. '"'
		end 
	end

	return st
end

--Формирование списка нс-серверов для добавления в БД
function format.db_nss( value )

	local st = ''

	if value then

		for i,v in pairs(value) do
			st = st .. i
			if type(v) ~= 'boolean' and #v > 0 then
				st = st .. '#'
				for i,u in pairs(v) do
					st = st .. u .. ','
				end
				--ngx.say(st)
				st = stringx.strip( st, ',' )
			end
			st = st .. ';'
		end
		st = stringx.strip( st, ';' )
	end
	return st
	-- body
end

--Получение списка нс-серверов из БД
function format.get_nss_from_db( tbl )

	local tmp = {} 
	local fin = {}

	for _,v in pairs(tbl) do

		if string.len(v.nss) ~= 0 then
			
			table.insert( tmp, v.nss )
		end
	end

	for _,v in pairs(tmp) do

		local tmp1 = stringx.split(v,';')
		
		for _,u in pairs(tmp1) do
			
			fin[stringx.split(u,':')[1]] = stringx.split(u,':')[2] or ''
		end
	end

	return fin
end

function format.add_or_rem_status( new, old, status )

	local t1,t2
	if status then
		t1 = tablex.map(
		function(v)
			if stringx.count( v, 'client' ) > 0 then return v end
		end, new)

		t2 = tablex.map(
		function(v)
			if stringx.count( v, 'client' ) > 0 then return v end
		end, old)
	else
		t1 = tablex.copy(new)
		t2 = tablex.copy(old)
	end

	local fin = {}
	fin.add = {}  
	fin.rem = {}
	local sql = {} 

	for i,v in pairs( t1 ) do
		if not tablex.find( t2, v ) then
			table.insert(fin.add,v)
		end
		table.insert(sql,v)
	end

	for i,v in pairs( t2 ) do
		if not tablex.find(sql,v) then
			table.insert(fin.rem,v)
		end
	end

	if status then
		for i,v in pairs(old) do
			if stringx.count( v, 'client' ) == 0 then table.insert(sql,v) end
		end
	end

	return fin, sql
end

--В случае если pcall возвратился с ошибкой генерирует ответ с ошибкой
function format.err( str )
	return { result = { { code = '4224', msg = 'Внутрення ошибка АПИ', reason = str } } }
end

--Начинает писать в базу клиентский лог и возвраащает ид операции
function format.QC_insert( obj, com, body, block )
	--local tmp = 'SELECT * FROM queueClient WHERE '
	--if block then
	local sql = 'INSERT INTO queueClient ( request, object, command, status, date ) VALUES ( ?, "' .. obj .. '", "' .. com .. '", "work", NOW() )'
	db.query( sql, body )
	clTRID = db.query('SELECT last_insert_id()')[1]['last_insert_id()']

	local blck
	if block then
		local sel = db.query( 'SELECT * FROM queueClient WHERE object = ? AND command = ? AND status = "abort"', obj, com )
		for i,v in pairs( sel ) do
			local tmp = util.from_json( v.request )
			--ngx.say(v.request)
			--ngx.say(tmp.name)
			if block == tmp.name then blck = 1 end
		end
	end

	return clTRID, blck
end

--Проверка стоп-листа
function format.check_stop_list( dmn, tld )

	local inspect = require 'inspect'

	local domain = utf8.lower( stringx.split( dmn, '.' )[1] )

	--local check  = false

	--для начала проверим просто на полное попадание.
	local sel = db.query( 'SELECT * FROM stop_list WHERE domain = ? AND tld = ?', domain, tld )

	if #sel > 0 then
		return true
	end

	--Если проскочили проверку в лоб, возьмем весь стоп-лист и проверим вхождение стоп домена в наш домен
	local sel = db.query( 'SELECT * FROM stop_list WHERE tld = ?', tld )

	for i,v in pairs( sel ) do
		if string.find( domain, v.domain ) then
			return true
		end
	end

	--print( '------------------------------------------------------------' )
	--print( inspect( sel ) )

	--print( #sel )
	--print( '------------------------------------------------------------' )

	return false
end


function format.block_trans( ... )
	-- body
end

return format