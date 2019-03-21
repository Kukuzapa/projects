local domain  = {}

--Модули ляписа
local db = require("lapis.db")

--Сторонние модули
local tablex  = require 'pl.tablex'
local stringx = require 'pl.stringx'

--Модули АПИ
local req_res = require "module.req_res"
local format  = require "module.format"
local contact = require 'module.contact'
local host    = require 'module.host'

function domain.copy( body )
	local info, icode = domain.get( body )

	if body.tr_status == 'abort' then
		return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
	end

	if icode ~= '1000' then
		return { result = { { code = '4404', msg = 'Нет объекта', reason = 'Такого домена нет в реестре' } } }
	end

	info = info.domain

	local select_domain = db.query( 'SELECT * FROM domains WHERE name = ? AND id_registrars = ?', body.name, body.regid )
	if #select_domain > 0 then
		db.query( 'DELETE FROM domains WHERE name = ? AND id_registrars = ?', body.name, body.regid )
	end

	local select_contact = db.query( 'SELECT * FROM contacts WHERE contact_id = ? AND id_registrars = ?', info.registrant, body.regid )
	if #select_contact == 0 then
		local tmp_body = tablex.copy( body )
		tmp_body.id = info.registrant
		local ccopy = contact.copy( tmp_body )

		if ccopy.result[1].code == '4444' then
			return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
		end
		
		if ccopy.result[1].code == '4404' then
			return { result = { { code = '4404', msg = 'Нет объекта владельца', reason = 'Владелец данного домена не заведен в реестре' } } }
		end
		select_contact = db.query( 'SELECT * FROM contacts WHERE contact_id = ? AND id_registrars = ?', info.registrant, body.regid )
	end

	local id_contacts = select_contact[1].id

	local nss = ''

	if info.hostObj then
		for i,v in pairs( info.hostObj ) do
			if stringx.count( v, '.' .. body.name ) > 0 then
				local hbody = tablex.copy( body )
				hbody.name = v
				--ngx.say( hbody.name )
				local hinfo = host.get(hbody)

				if hinfo.result[1].code == '4444' or hinfo.result[1].code == 'CRITICAL ERROR' then
					body.tr_status = 'abort'
					return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
				end

				if hinfo.host then
					local ip = ''
					--ngx.say( hinfo.name )
					if hinfo.host.v4 then
						for i,v in pairs( hinfo.host.v4 ) do
							ip = ip .. v .. ','
						end
					end
					if hinfo.host.v6 then
						for i,v in pairs( hinfo.host.v6 ) do
							ip = ip .. v .. ','
						end
					end
					if string.len( ip ) > 0 then
						nss = nss .. v .. '#' .. stringx.strip( ip, ',' ) .. ';'
					else
						nss = nss .. v .. ';'
					end
				end
			else
				nss = nss .. v .. ';'
			end
		end
		nss = stringx.strip( nss, ';' )
	end

	local sql = 'INSERT INTO domains ( %s id_registrars, id_contacts, name ) VALUES (%s' .. tostring(body.regid) ..',"' .. id_contacts .. '","' .. body.name .. '")'
	local var = ''
	local val = ''

	local templ = { description = 'description', status = 'status', authInfo = 'authInfo' }
	for i,v in pairs( info ) do
		if templ[i] then
			var = var .. templ[i] .. ','
			val = val .. format.set_string_into_db( v ) .. ','
		end
	end

	local templ = { crDate = 'crdate', upDate = 'upddate', exDate = 'exdate', trDate = 'trdate' }
	for i,v in pairs( templ ) do
		if info[i] then
			local time = {}
			time.year, time.month, time.day, time.hour, time.min, time.sec = string.match( info[i], "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)." )
			var = var .. v .. ','
			val = val .. '"' .. os.date( '%Y-%m-%d %X', os.time( time ) + 18000 ) .. '",'
		end
	end

	if string.len( nss ) > 0 then
		var = var .. 'nss,'
		val = val .. '"' .. nss .. '",'
	end

	sql = string.format( sql, var, val )
	db.query( sql )
	
	return { result = { { code = '4200', msg = 'Успех', reason = 'Объект домен скопирован' } } }
end


--Создание домена
function domain.create( body )
	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]

	body.obj = 'domain'
	body.command = 'create'
	body.regid = select_registar.id

	if format.check_stop_list( body.name, body.regid ) then
		body.tr_status = 'done'
		return { result = { { code = '7778', msg = 'Указанное вами имя домена находится в стоп-листе зоны ' .. body.reg .. '.' } } }
	end

	--Работаем по связанному контакту, если контакта нет в бд, копируем его и сохраняем ид или выдаем ошибку
	local select_contact = db.query( 'SELECT * FROM contacts WHERE contact_id = ? AND id_registrars = ?', body.registrant, body.regid )
	if #select_contact == 0 then
		local cbody = tablex.copy( body )
		cbody.id = body.registrant
		local ccopy = contact.copy( cbody )

		if ccopy.result[1].code == '4444' then
			body.tr_status = 'abort'
			return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
		end

		if ccopy.result[1].code == '4404' then
			body.tr_status = 'done'
			return { result = { { code = '4404', msg = 'Нет объекта владельца', reason = 'Владелец данного домена не заведен в реестре' } } }
		end
		select_contact = db.query( 'SELECT * FROM contacts WHERE contact_id = ? AND id_registrars = ?', body.registrant, body.regid )
	end

	local id_contacts = select_contact[1].id

	--Работаем по связанным хостам
	local hostObj = {}

	if body.nss then
		hostObj = tablex.copy( body.nss )
	end

	local check
	if #hostObj > 0 then
		local cbody = tablex.copy( body )
		cbody.name  = tablex.copy( hostObj )
		check = host.check( cbody )

		if check.result[1].code == '4444' or check.result[1].code == 'CRITICAL ERROR' then
			body.tr_status = 'abort'
			return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
		end
		
		if check.result[1].code == '2005' then
			body.tr_status = 'done'
			return { result = { { code = '4404', msg = 'Ошибка в имени НС-Сервера' } } }
		end

		for i,v in pairs( hostObj ) do
			if check.check[v] == '1' then
				local crbody = tablex.copy( body )
				crbody.name = v
				local hcr = host.create( crbody )

				if hcr.result[1].code == '4444' or hcr.result[1].code == 'CRITICAL ERROR' then
					body.tr_status = 'abort'
					return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
				end
			end
		end
	else
		hostObj = nil
	end
	------------------------------------------------------------------
	
	local epp, add = format.epp_template( body.command, body.obj )	

	add.kids = {}

	add.kids = format.set_objects_name_id( add.kids, body.obj, body.name )

	add.kids = format.set_domain_hostObj( add.kids, hostObj )
	add.kids = format.set_string( add.kids, body.obj, 'registrant', body.registrant )
	add.kids = format.set_string( add.kids, body.obj, 'description', body.description )
	add.kids = format.set_auth( add.kids, body.obj, body.authInfo )

	local resp, tmp_resp, rcode = req_res.req( body, epp )

	if body.tr_status == 'abort' then
		return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
	end

	if tmp_resp and tablex.search( tmp_resp, 'creData' ) then
		resp[body.command] = {}

		local template = { 'name', 'id', 'crDate', 'exDate' }

		for _,v in pairs( template ) do
			format.get_string( tmp_resp, v, resp[body.command] )
		end
	end

	--Пишем в БД
	if rcode and rcode == '1000' then

		local sql = 'INSERT INTO domains ( %s id_registrars, id_contacts, name, crdate, exdate ) VALUES (%s' .. 
			tostring(body.regid) ..',"' .. id_contacts .. '","' .. body.name .. '", NOW(), NOW()+INTERVAL 1 YEAR )'
		local var = ''
		local val = ''

		local templ = { description = 'description', status = 'status', authInfo = 'authInfo' }
		for i,v in pairs( body ) do
			if templ[i] then
				var = var .. templ[i] .. ','
				val = val .. format.set_string_into_db( v ) .. ','
			end
		end

		if hostObj then
			var = var .. 'nss,'
			val = val .. '"' .. table.concat( hostObj, ';' ) .. '",'
		end

		sql = string.format( sql, var, val )

		--ngx.say(sql)

		db.query( sql )
	end

	--Добавляем адреса в дочерние нс-сервера
	if body.subnss and rcode == '1000' then
		
		local bad_nss
		for i,v in pairs( body.subnss ) do
			
			local uhbody = tablex.copy( body )
			uhbody.name = i
			uhbody.ip = tablex.copy( v )

			local ucode,uip = host.update( uhbody )

			if ucode == '1000' then
				uip = table.concat( uip, ',' )

				for j,u in pairs( hostObj ) do
					if u == i then
						hostObj[j] = u .. '#' .. uip
					end
				end
			else
				bad_nss = 1
			end
		end

		local tmp = table.concat( hostObj, ';' )

		local sql = 'UPDATE domains SET nss = "' .. tmp .. '" WHERE name = "' .. body.name .. '"'

		db.query( sql )

		if bad_nss then
			table.insert( resp.result, { code = '4200', msg = 'Не удалось добавить дочерние НС-Сервера' } )
		else
			table.insert( resp.result, { code = '4200', msg = 'Дочерние НС-Сервера успешно добавлены' } )
		end
	end

	return resp, rcode, tmp_resp
end

--Информация от домена
function domain.get( body )
	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]

	body.obj = 'domain'
	body.command = 'info'
	body.regid = select_registar.id

	local epp, add = format.epp_template( body.command, body.obj )

	add.kids = {}

	add.kids = format.set_objects_name_id( add.kids, body.obj, body.name )

	add.kids = format.set_auth( add.kids, body.obj, body.authInfo )

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

--Проверка занятости
function domain.check( body )
	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]

	body.obj = 'domain'
	body.command = 'check'
	body.regid = select_registar.id
	
	local epp, add = format.epp_template( body.command, body.obj )

	add.kids = {}

	add.kids = format.set_objects_name_id( add.kids, body.obj, body.name )

	local resp, tmp_resp, rcode = req_res.req( body, epp )

	if body.tr_status == 'abort' then
		return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
	end

	if tmp_resp and tablex.search( tmp_resp, 'chkData' ) then
		resp[body.command] = {}
		format.get_check( tmp_resp, resp[body.command], 'name' )
	end

	return resp, rcode
end

--Удаление домена
function domain.delete( body )
	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]

	body.obj = 'domain'
	body.command = 'delete'
	body.regid = select_registar.id

	local epp, add = format.epp_template( body.command, body.obj )

	add.kids = {}

	add.kids = format.set_objects_name_id( add.kids, body.obj, body.name )

	local resp, tmp_resp, rcode = req_res.req( body, epp )

	if body.tr_status == 'abort' then
		return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
	end

	if rcode and rcode == '1000' then
		local select_domain = db.query( 'SELECT * FROM domains WHERE name = ? AND id_registrars = ?', body.name, body.regid )[1]

		db.query( 'DELETE FROM domains WHERE name = ? AND id_registrars = ?', body.name, body.regid )

		if select_domain then
			local count_domain = db.query( 'SELECT * FROM domains WHERE id_contacts = ? AND id_registrars = ?', select_domain.id_contacts, body.regid )
			if #count_domain == 0 then
				db.query( 'DELETE FROM contacts WHERE id = ? AND id_registrars = ?', select_domain.id_contacts, body.regid )
			end
		end
	end

	return resp, rcode
end

--Редактирование
function domain.update( body )
	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]

	body.obj = 'domain'
	body.command = 'update'
	body.regid = select_registar.id

	local select_domain = db.query( 'SELECT * FROM domains WHERE name = ? AND id_registrars = ?', body.name, body.regid )[1]

	if not select_domain then
		local ibody = tablex.copy( body )
		ibody.command = 'info'
		local copy = domain.copy( ibody )

		if copy.result[1].code == '4444' then
			body.tr_status = 'abort'
			return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
		end

		if copy.result[1].code == '4404' then
			body.tr_status = 'done'
			return { result = { { code = '4404', msg = 'Нет объекта', reason = 'Такого домена не существует' } } }
		end

		body.tr_status = 'done'
		return { result = { { code = '4407', msg = 'Операция отменена АПИ', reason = [[Вы попытались провести операцию над объектом, которого нет в БД. Сейчас мы его туда добавили. Попробуйте еще раз.]] } } }

		--select_domain = db.query( 'SELECT * FROM domains WHERE name = ? AND id_registrars = ?', body.name, body.regid )[1]
	end

	local old_nss
	local new_nss = {}
	local nss, sql_nss
	if body.nss then
		if type( select_domain.nss ) == 'userdata' then select_domain.nss = '' end

		old_nss = stringx.split( select_domain.nss, ';' )

		for i,v in pairs( old_nss ) do
			old_nss[i] = stringx.split( v, '#' )[1]
		end

		for i,v in pairs( body.nss ) do
			table.insert( new_nss, i )
		end

		nss, sql_nss = format.add_or_rem_status( new_nss, old_nss )

		
		
		local no_touch_host = {}
		for i,v in pairs ( sql_nss ) do
			if not tablex.find( nss.add, v ) and type( body.nss[v] ) == 'table' then
				local up_body = tablex.copy( body )
				up_body.name = v
				up_body.ip = body.nss[v]
				local upd, list = host.update( up_body )

				if upd == '4444' or upd == 'CRITICAL ERROR' then
					body.tr_status = 'abort'
					return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
				end

				if upd == '2005' then
					body.tr_status = 'done'
					return { result = { { code = '4404', msg = 'Ошибка в адресе НС-Сервера' } } }
				end
				
				if list and #list > 0 then
					local tmp = ''
					for i,v in pairs( list ) do
						tmp = tmp .. v .. ','
					end
					sql_nss[ i ] = sql_nss[ i ] .. '#' .. stringx.strip( tmp, ',' )
				end
			end
		end

		if #nss.add > 0 then
			local ch_body = tablex.copy( body )
			ch_body.name = tablex.copy( nss.add )
			local check = host.check( ch_body )

			if check.result[1].code == '4444'or check.result[1].code == 'CRITICAL ERROR' then
				body.tr_status = 'abort'
				return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
			end

			if check.result[1].code == '2005' then
				body.tr_status = 'done'
				return { result = { { code = '4404', msg = 'Ошибка в имени НС-Сервера' } } }
			end

			for i,v in pairs( check.check ) do
				if v == '0' then
					if type( body.nss[i] ) == 'table' then
						local up_body = tablex.copy( body )
						up_body.name = i
						up_body.ip = body.nss[i]
						local upd, list = host.update( up_body )

						if upd == '4444' or upd == 'CRITICAL ERROR' then
							body.tr_status = 'abort'
							return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
						end

						if upd == '2005' then
							body.tr_status = 'done'
							return { result = { { code = '4404', msg = 'Ошибка в адресе НС-Сервера' } } }
						end
						if list and #list > 0 then
							local tmp = ''
							for i,v in pairs( list ) do
								tmp = tmp .. v .. ','
							end
							sql_nss[ tablex.find( sql_nss, i ) ] = sql_nss[ tablex.find( sql_nss, i ) ] .. '#' .. stringx.strip( tmp, ',' )
						end
					end
				end
				if v == '1' then
					local cr_body = tablex.copy( body )
					cr_body.name = i
					cr_body.ip = body.nss[i]
					
					local cr = host.create( cr_body )

					if cr.result[1].code == '4444' or cr.result[1].code == 'CRITICAL ERROR' then
						body.tr_status = 'abort'
						return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
					end
					
					if cr_body.ip and type( cr_body.ip ) == 'table' and #cr_body.ip > 0 then
						local tmp = ''
						for i,v in pairs( cr_body.ip ) do
							tmp = tmp .. v .. ','
						end
						sql_nss[ tablex.find( sql_nss, i ) ] = sql_nss[ tablex.find( sql_nss, i ) ] .. '#' .. stringx.strip( tmp, ',' )
					end
				end
			end

			body.add = {}
			body.add.hostObj = nss.add
		end
		if #nss.rem > 0 then
			body.rem = {}
			body.rem.hostObj = nss.rem
		end
	end
	
	local new_status, sql_status
	if body.status then
		if type( body.status ) ~= 'table' then body.status = {} end
		if type( select_domain.status ) == 'userdata' then select_domain.status = '' end

		new_status, sql_status = format.add_or_rem_status( body.status, stringx.split( select_domain.status or '', ';' ), 'status' )
		--ngx.say( #new_status.add, ' ', #new_status.rem )
		if #new_status.add > 0 then
			if not body.add then body.add = {} end
			body.add.status = new_status.add
		end
		if #new_status.rem > 0 then
			if not body.rem then body.rem = {} end
			body.rem.status = new_status.rem
		end
	end

	local new_registrant_id
	if body.registrant then
		local select_contact = db.query( 'SELECT * FROM contacts WHERE contact_id = ? AND id_registrars = ?', body.registrant, body.regid )[1]
		if not select_contact then
			local ibody = tablex.copy( body )
			ibody.command = 'info'
			ibody.id = body.registrant
			local copy = contact.copy( ibody )

			if copy.result[1].code == '4444' then
				body.tr_status = 'abort'
				return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
			end

			if copy.result[1].code == '4404' then
				body.tr_status = 'done'
				return { result = { { code = '4404', msg = 'Нет объекта', reason = 'Такого контакта не существует' } } }
			end

			select_contact = db.query( 'SELECT * FROM contacts WHERE contact_id = ? AND id_registrars = ?', body.registrant, body.regid )[1]
		end
		new_registrant_id = select_contact.id
		--ngx.say(new_registrant_id)
	end

	local chg = {}

	chg.registrant = body.registrant
	chg.description = body.description
	chg.authInfo = body.authInfo

	if tablex.size( chg ) > 0 then body.chg = tablex.copy( chg ) end

	local epp, add = format.epp_template( body.command, body.obj )

	add.kids = {}

	add.kids = format.set_objects_name_id( add.kids, body.obj, body.name )

	if body.add then
		local sadd = format.make_child_table( body.obj .. ':add', nil, nil, 'Children are the flowers of life' )
		sadd.kids = format.set_domain_hostObj( sadd.kids, body.add.hostObj )
		sadd.kids = format.set_status( sadd.kids, body.obj, body.add.status )
		if #sadd.kids > 0 then table.insert( add.kids, sadd ) end
	end

	if body.rem then
		local sadd = format.make_child_table( body.obj .. ':rem', nil, nil, 'Children are the flowers of life' )
		sadd.kids = format.set_domain_hostObj( sadd.kids, body.rem.hostObj )
		sadd.kids = format.set_status( sadd.kids, body.obj, body.rem.status )
		if #sadd.kids > 0 then table.insert( add.kids, sadd ) end
	end

	if body.chg then
		local schg = format.make_child_table( body.obj .. ':chg', nil, nil, 'Children are the flowers of life' )
		schg.kids = format.set_string( schg.kids, body.obj, 'registrant', body.chg.registrant )
		schg.kids = format.set_string( schg.kids, body.obj, 'description', body.chg.description )
		schg.kids = format.set_auth( schg.kids, body.obj, body.chg.authInfo )
		if #schg.kids > 0 then table.insert( add.kids, schg ) end
	end

	local resp, tmp_resp, rcode = req_res.req( body, epp )

	if body.tr_status == 'abort' then
		return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
	end

	if rcode and rcode == '1000' then
		local sql = 'UPDATE domains SET %s upddate = NOW() WHERE id_registrars = ? AND name = ?'
		local set = ''

		if new_registrant_id then
			set = set .. 'id_contacts = ' .. new_registrant_id .. ','
		end

		if sql_nss and #sql_nss > 0 then
			set = set .. 'nss = "'
			for _,v in pairs( sql_nss ) do
				set = set .. v .. ';'
			end
			set = stringx.strip( set, ';' )
			set = set .. '",'
		else
			set = set .. 'nss = NULL,'
		end

		if sql_status then
			set = set .. 'status = '
			set = set .. format.set_string_into_db( sql_status )
			set = set .. ','

			--ngx.say(set)
		end

		if body.description then
			set = set .. 'description = "' .. body.description .. '",'
		end

		if body.authInfo then
			set = set .. 'authInfo = "' .. body.authInfo .. '",'
		end

		sql = string.format( sql, set )
		--ngx.say( sql )

		db.query( sql, body.regid, body.name )
	end
	return resp, rcode
end

--Продление домена (не тестировалось в бою)
function domain.renew( body )
	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]

	body.obj = 'domain'
	body.command = 'renew'
	body.regid = select_registar.id
	
	local epp, add = format.epp_template( body.command, body.obj )

	add.kids = {}

	add.kids = format.set_objects_name_id( add.kids, body.obj, body.name )
	add.kids = format.set_string( add.kids, body.obj, 'curExpDate', body.curExpDate )

	local resp, tmp_resp, rcode = req_res.req( body, epp )

	if body.tr_status == 'abort' then
		return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
	end

	if tmp_resp and tablex.search( tmp_resp, 'renData' ) then
		resp[body.command] = {}

		local template = { 'name', 'exDate' }

		for _,v in pairs( template ) do
			format.get_string( tmp_resp, v, resp[body.command] )
		end
	end

	return resp, rcode
end

--Трансфер домена (не тестировалось в бою)
function domain.transfer( body )
	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]

	body.obj = 'domain'
	body.command = 'transfer'
	body.regid = select_registar.id
	
	local epp, add = format.epp_template( body.command, body.obj, body.transfer )

	add.kids = {}

	add.kids = format.set_objects_name_id( add.kids, body.obj, body.name )
	add.kids = format.set_auth( add.kids, body.obj, body.authInfo )

	local resp, tmp_resp, rcode = req_res.req( body, epp )

	if body.tr_status == 'abort' then
		return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
	end

	if tmp_resp and tablex.search( tmp_resp, 'trnData' ) then
		resp[body.command] = {}

		local template = { 'name', 'trStatus', 'reID', 'reDate', 'acID', 'acDate', 'exDate' }

		for _,v in pairs( template ) do
			format.get_string( tmp_resp, v, resp[body.command] )
		end
	end

	return resp, rcode
end

function domain.host_info( body )
	return host.get( body )
	-- body
end

function domain.host_update( body )
	return host.update( body )
	-- body
end

return domain