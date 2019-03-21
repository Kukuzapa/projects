local registrar = {}

--Модули АПИ
local req_res = require "module.req_res"
local format  = require 'module.format'
local domain  = require 'module.domain'

--Модули ляписа
local db = require("lapis.db")

--Модуль работы с таблицами библиотеки penlight
local tablex   = require 'pl.tablex'
local stringx  = require 'pl.stringx'

--Информация о регистраторе
function registrar.get( body )
	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]

	body.obj = 'registrar'
	body.command = 'info'
	body.regid = select_registar.id

	local epp, add = format.epp_template( body.command, body.obj )

	add.kids = {}

	add.kids = format.set_objects_name_id( add.kids, body.obj, 'REGFORMAT-' .. body.reg )

	local resp, tmp_resp, rcode = req_res.req( body, epp )

	if body.tr_status == 'abort' then
		return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
	end

	if tmp_resp and tablex.search( tmp_resp, 'infData' ) then

		resp[body.obj] = {}

		format.get_status( tmp_resp, resp[body.obj] )
		format.get_authInfo( tmp_resp, resp[body.obj] )
		format.get_ip( tmp_resp, resp[body.obj] )
		format.get_verified( tmp_resp, resp[body.obj] )
		format.get_contact_type( tmp_resp, resp[body.obj] )
		format.get_domain_hostObj( tmp_resp, resp[body.obj] )

		format.get_objects_name_id( tmp_resp, body.obj, resp[body.obj] )		

		local strgs = { 'birthday', 'taxpayerNumbers', 'clID', 'crDate', 'upDate', 'trDate', 'roid', 'registrant', 'crID', 'exDate', 'whois', 'www', 'pw' }
		for _,v in pairs(strgs) do
			format.get_string( tmp_resp, v, resp[body.obj] )
		end

		local tbls = { 'voice', 'fax', 'email', 'passport', 'description' }
		for _,v in pairs(tbls) do
			format.get_arrays( tmp_resp, v, resp[body.obj] )
		end

		local postal = { 'intPostalInfo', 'locPostalInfo', 'legalInfo' }
		for _,v in pairs(postal) do
			format.get_postal( tmp_resp, v, resp[body.obj] )
		end

		if body.obj == 'registrar' then
			format.get_registrar_email ( tmp_resp, resp[body.obj] ) 
		end
	end

	return resp, rcode, tmp_resp
end

--Редактирование Регистратора. Меняет только ip.
function registrar.update( body )
	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]

	body.obj = 'registrar'
	body.command = 'update'
	body.regid = select_registar.id
	
	local clid = 'REGFORMAT-' .. body.reg --Ид регистратора

	local epp, add = format.epp_template( body.command, body.obj )

	add.kids = {}

	add.kids = format.set_objects_name_id( add.kids, body.obj, clid )

	local info = registrar.get( body )

	if body.tr_status == 'abort' then
		return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
	end

	if info.result[1].code == '1000' then

		local old_ip = {}
		if info.registrar.v4 and tablex.size( info.registrar.v4 ) > 0 then
			old_ip = tablex.copy( info.registrar.v4 )
		end

		if info.registrar.v6 and tablex.size( info.registrar.v6 ) > 0 then
			for i,v in pairs( info.registrar.v6 ) do
				table.insert( old_ip, v )
			end
		end

		local fin = format.add_or_rem_status( body.ip, old_ip )

		local templ = { 'add', 'rem' }
		for i,v in pairs( templ ) do
			if tablex.size( fin[v] ) > 0 then
				local tmp = format.make_child_table( body.obj .. ':' .. v, nil, nil, 'Children are the flowers of life' )
				tmp.kids  = format.set_ip( tmp.kids, fin[v], body.obj )
				table.insert( add.kids, tmp )
			end
		end
	else
		return { result = { { code = '4404', msg = 'Не удалось получить информацию о регистраторе' } } }
	end

	local resp, tmp_resp = req_res.req( body, epp )

	if body.tr_status == 'abort' then
		return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
	end

	return resp
end

--Начало сессии с реестром
function registrar.newPass( body )

	local clid = 'REGFORMAT-' .. body.reg --Формирование идентификатора регистратора

	--Считываем текущий пароль из БД
	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]
	--Если пароля нет, берет некий пароль из строки ниже, нужно в случае отсутствия пароля в БД
	if not select_registar then 
		current_password = 'fake_pass' 
	else
		current_password = select_registar.password
	end

	body.regid = select_registar.id
	body.obj = 'registrar'
	body.command = 'password'

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
	
	if body.newPW then
		table.insert( login.kids, 3, format.make_child_table( 'newPW', body.newPW ) ) 
	else
		local resp = {}
		resp.error = 'Не указан новый пароль'
		return resp
	end
	
	--Полная таблица команды
	local main_attr = {
		xmlns                  = 'http://www.ripn.net/epp/ripn-epp-1.0',
		['xmlns:xsi']          = 'http://www.w3.org/2001/XMLSchema-instance',
		['xsi:schemaLocation'] = 'http://www.ripn.net/epp/ripn-epp-1.0 ripn-epp-1.0.xsd'
	}
	local epp = format.make_child_table( 'epp', nil, main_attr, 'Children are the flowers of life' )

	local command = format.make_child_table( 'command', nil, nil, 'Children are the flowers of life' )

	table.insert( command.kids, login )
	table.insert( command.kids, format.make_child_table( 'clTRID' ) )

	table.insert( epp.kids, command )
	
	local resp, tmp_resp = req_res.req( body, epp )

	if body.tr_status == 'abort' then
		return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
	end

	--Если смена пароля была инициирована и ответ положительный, сделаем запись в журнал смены пароля, обновим таблицу текущего пароля
	if resp.result[1].code == '1000' then
		db.query( 'UPDATE registrars SET password = ? WHERE registrar = ?', body.newPW, body.reg )
	end

	return resp
end

--Заканчиваем работу, рвем сессию
function registrar.logout( conn, body )
	
	local main_attr = {
		xmlns                  = 'http://www.ripn.net/epp/ripn-epp-1.0',
		['xmlns:xsi']          = 'http://www.w3.org/2001/XMLSchema-instance',
		['xsi:schemaLocation'] = 'http://www.ripn.net/epp/ripn-epp-1.0 ripn-epp-1.0.xsd'
	}
	
	local epp = format.make_child_table( 'epp', nil, main_attr, 'Children are the flowers of life' )

	local command = format.make_child_table( 'command', nil, nil, 'Children are the flowers of life' )
	table.insert( command.kids, format.make_child_table( 'logout' ) )
	table.insert( command.kids, format.make_child_table( 'clTRID' ) )

	table.insert( epp.kids, command )

	local tmp_resp, resp = req_res.req( conn, epp )
	
	return resp
end

--Привет!
function registrar.hello( body )

	local main_attr = {
		xmlns                  = 'http://www.ripn.net/epp/ripn-epp-1.0',
		['xmlns:xsi']          = 'http://www.w3.org/2001/XMLSchema-instance',
		['xsi:schemaLocation'] = 'http://www.ripn.net/epp/ripn-epp-1.0 ripn-epp-1.0.xsd'
	}
	
	local epp = format.make_child_table( 'epp', nil, main_attr, 'Children are the flowers of life' )
	table.insert( epp.kids, format.make_child_table( 'hello' ) )

	local tmp_resp, resp = req_res.hello( body, epp )

	return tmp_resp
end

--Запрос сообщений реестра
--TO DO протестировать
function registrar.poll( body )
	local util = require("lapis.util")
	local idn    = require 'module.punycode.idn'

	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]

	body.obj = 'registrar'
	body.command = 'poll'
	body.regid = select_registar.id

	local select_polls = db.query( 'SELECT * FROM temp_poll_count WHERE reg = ? ORDER BY id DESC', body.reg )

	if #select_polls == 0 then
		body.tr_status = 'done'
		return { result = { { code = '4200', msg = 'В реестре нет сообщений' } } }
	end

	local test = {}
	local count = 0

	--for i,v in pairs( select_polls ) do
	while #select_polls > 0 do
		count = count + 1

		local epp = format.poll( 'req' )

		local resp, tmp_resp, rcode, resp_xml = req_res.req( body, epp )

		if body.tr_status == 'abort' then
			return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
		end

		if tmp_resp and tablex.search( tmp_resp, 'trnData' ) then

			local tmp = {}
			tmp.msg_id = select_polls[1].count
			format.get_string( tmp_resp, 'trStatus', tmp )
			format.get_string( tmp_resp, 'name', tmp )
			format.get_string( tmp_resp, 'reID', tmp )
			format.get_string( tmp_resp, 'reDate', tmp )
			format.get_string( tmp_resp, 'acID', tmp )
			format.get_string( tmp_resp, 'acDate', tmp )
			format.get_string( tmp_resp, 'exDate', tmp )
			table.insert(test,tmp)
			--test = tmp

			--if tmp.trStatus == 'clientApproved' then
			--15.10.2018 поменял условие на запись трансфера в нашу БД
			if tmp.trStatus == 'serverApproved' then
				local copy_body = tablex.copy( body )
				copy_body.name = idn.decode(tmp.name)
				local copy = domain.copy( copy_body )

				if copy.result[1].code == '4444' then
					return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения', reason = 'Есть мнение, что домен в БД не скопирован' } } }
				end
			end
			--resp[body.command] = {}

			--local template = { 'name', 'trStatus', 'reID', 'reDate', 'acID', 'acDate', 'exDate' }

			--for _,v in pairs( template ) do
			--	format.get_string( tmp_resp, v, resp[body.command] )
			--end
		end

		--По идее здесь надо вставлять что-то осмысленное в таблицу polls, но пока у нас нет четкого понимания, что и как там может быть, будем пихать xml
		if resp_xml then
			db.query( 'INSERT INTO polls ( msg_id, msg_text, id_registrars, msg_date ) VALUES ( ?, ?, ?, NOW() )', select_polls[1].count, string.gsub( resp_xml, '\n', '' ), body.regid )
		end

		epp = format.poll( 'ack', select_polls[1].count )		

		resp, tmp_resp, rcode, resp_xml = req_res.req( body, epp )

		if body.tr_status == 'abort' then
			return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
		end

		db.query( 'DELETE FROM temp_poll_count WHERE reg = ? AND count = ?', body.reg, select_polls[1].count )

		select_polls = db.query( 'SELECT * FROM temp_poll_count WHERE reg = ? ORDER BY id DESC', body.reg )
	end

	return { result = { { code = '4200', msg = 'Кол-во сообщений реестра записанных в БД - ' .. count } }, poll = test }
end

--Запрос информации о биллинге
function registrar.billing( body )
	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]

	body.obj = 'registrar'
	body.command = 'billing'
	body.regid = select_registar.id
	
	local epp, add = format.billing()

	add.kids = {}

	add.kids = format.set_string( add.kids, 'billing', 'type', body.billing )

	if body.currency or body.date or body.period then

		local param = format.make_child_table( 'billing:param', nil, nil, 'Children are the flowers of life' )

		param.kids = format.set_string( param.kids, 'billing', 'date', body.date )

		if body.period then
			local tmp_prd = {body.period:match("(%w),(%d+)")}
  		
  			local period = format.make_child_table( 'billing:period', tmp_prd[2], { ['unit'] = tmp_prd[1] } )
  		
  			table.insert(param.kids, period)
  		end
		
		param.kids = format.set_string( param.kids, 'billing', 'currency', body.currency )

		table.insert(add.kids, param)
	end

	local resp, tmp_resp = req_res.req( body, epp )

	if body.tr_status == 'abort' then
		return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
	end

	if tmp_resp and tablex.search( tmp_resp, body.billing ) then

		resp[body.billing] = {}

		local find = {}

		format.find( tmp_resp, body.billing, find )

		if #find > 0 then

			for i,v in pairs(find[1].kids) do

				if v.name == 'service' then
				
					local tmp = {}
				
					for i,v in pairs(v.kids) do
						tmp[v.name] = v.text
					end
				
					table.insert(resp[body.billing],tmp)
				else
					resp[body.billing][v.name] = v.text
				end
			end
		end
	end

	return resp
end

--Запрос лимитов
function registrar.limits( body )
	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]

	body.obj = 'registrar'
	body.command = 'limits'
	body.regid = select_registar.id

	local epp = format.limits()

	local resp, tmp_resp = req_res.req( body, epp )

	if body.tr_status == 'abort' then
		return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
	end

	local find = {}

	if tmp_resp then format.find( tmp_resp, 'limit', find ) end

	if #find > 0 then

		resp['limits'] = {}

		for i,v in pairs(find) do
			
			resp['limits'][v.attr.name] = {}
			
			for i,u in pairs(v.kids) do
				resp['limits'][v.attr.name][u.name] = u.text
			end
		end
	end

	return resp
end

--Запрос stat
function registrar.stat( body )
	--all, domain, domain_pending_transfer, domain_pending_delete, contact, host
	--Реальный список значений параметра name, котоорые срабатывают на 06.04.18
	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]

	body.obj = 'registrar'
	body.command = 'stat'
	body.regid = select_registar.id

	local epp, add = format.stat()

	add.kids = {}

	local mtrc = body.object
	if body.pending then
		mtrc = mtrc .. '_pending_' .. body.pending
	end

	local metric = format.make_child_table( 'stat:metric', nil, { ['name'] = mtrc } )

	table.insert( add.kids, metric )

	local resp, tmp_resp, rcode, xml = req_res.req( body, epp )

	if body.tr_status == 'abort' then
		return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
	end

	--ngx.say( xml )

	return resp
end

--Тестовое сообщение
function registrar.test( conn, body )
	
	local resp = {}

	if conn then
		resp.connection = {}
		for i,v in pairs( conn ) do
			resp.connection[i] = v
		end
	end

	if body then
		resp.body = {}
		for i,v in pairs( body ) do
			resp.body[i] = v
		end
	end

	resp.test = 'Hello, world!'

	return resp
end

return registrar