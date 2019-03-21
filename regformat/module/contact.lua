local contact = {}

local db = require("lapis.db")

local format  = require 'module.format'
local req_res = require 'module.req_res'
local stringx = require 'pl.stringx'
local tablex  = require 'pl.tablex'

--Удаляем контакт
function contact.delete( body )
	local epp, add = format.epp_template( 'delete', 'contact' )

	add.kids = {}

	add.kids = format.set_objects_name_id( add.kids, 'contact', body.id )

	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]
	
	body.obj = 'contact'
	body.command = 'delete'
	body.regid = select_registar.id

	local is_success, resp, tmp_resp, rcode = pcall( req_res.req, body, epp )

	if not is_success then resp = format.err( resp ) end

	if body.tr_status == 'abort' then
		return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
	end

	if rcode and rcode == '1000' then
		local sql = string.format( 'DELETE FROM contacts WHERE contact_id = "%s" AND id_registrars = "%s"',
			body.id, select_registar.id )
		db.query( sql )
	end

	return resp, rcode, tmp_resp
end

--Проверяем доступность идентификатора контакта
function contact.check( body )
	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]

	body.obj = 'contact'
	body.command = 'check'
	body.regid = select_registar.id

	local epp, add  = format.epp_template( body.command, body.obj )

	add.kids = {}

	add.kids = format.set_objects_name_id( add.kids, body.obj, body.id )

	local resp, tmp_resp, rcode = req_res.req( body, epp )

	if body.tr_status == 'abort' then
		return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
	end

	if tmp_resp and tablex.search( tmp_resp, 'chkData' ) then
		resp[body.command] = {}
		format.get_check( tmp_resp, resp[body.command], 'id' )
	end

	return resp, rcode
end

--Обновляем контакт
function contact.update( body )
	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]

	body.obj = 'contact'
	body.command = 'update'
	body.regid = select_registar.id

	local select_contact = db.query( 'SELECT * FROM contacts WHERE contact_id = ? AND id_registrars = ?', body.id, body.regid )[1]

	if not select_contact then
		local ibody = tablex.copy( body )
		ibody.command = 'info'
		local copy = contact.copy( ibody )

		if copy.result[1].code == '4444' then
			body.tr_status = 'abort'
			return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
		end

		if copy.result[1].code == '4404' then
			body.tr_status = 'done'
			return { result = { { code = '4404', msg = 'Нет объекта', reason = 'Такого контакта не существует' } } }
		end
		select_contact = db.query( 'SELECT * FROM contacts WHERE contact_id = ? AND id_registrars = ?', body.id, body.regid )[1]
	end

	body.type = select_contact.type

	local new_status, sql_status
	if body.status then
		if type( body.status ) == 'boolean' then body.status = {} end
		if type( select_contact.status ) == 'userdata' then select_contact.status = '' end

		new_status, sql_status = format.add_or_rem_status( body.status, stringx.split( select_contact.status or '', ';' ), 'status' )
		if #new_status.add > 0 then
			body.add = {}
			body.add.status = new_status.add
		end
		if #new_status.rem > 0 then
			body.rem = {}
			body.rem.status = new_status.rem
		end
	end

	local epp, add = format.epp_template( body.command, body.obj )

	add.kids = {}

	add.kids = format.set_objects_name_id( add.kids, body.obj, body.id )

	if body.add then
		local sadd = format.make_child_table( body.obj .. ':add', nil, nil, 'Children are the flowers of life' )
		sadd.kids = format.set_status( sadd.kids, body.obj, body.add.status )
		if #sadd.kids > 0 then table.insert( add.kids, sadd ) end
	end

	if body.rem then
		local sadd = format.make_child_table( body.obj .. ':rem', nil, nil, 'Children are the flowers of life' )
		sadd.kids = format.set_status( sadd.kids, body.obj, body.rem.status )
		if #sadd.kids > 0 then table.insert( add.kids, sadd ) end
	end

	if body.chg then
		local schg = format.make_child_table( body.obj .. ':chg', nil, nil, 'Children are the flowers of life' )

		local ctype = format.make_child_table( body.obj .. ':' .. body.type, nil, nil, 'Children are the flowers of life' )

		local postal = { 'intPostalInfo', 'locPostalInfo', 'legalInfo' }
		local strgs  = { 'taxpayerNumbers', 'birthday', 'passport', 'voice', 'fax', 'email' }

		for _,v in pairs(postal) do
			ctype.kids = format.set_postal_info( ctype.kids, body.obj, v, body.chg[v], body.type )
		end

		for _,v in pairs(strgs) do
			ctype.kids = format.set_string( ctype.kids, body.obj, v, body.chg[v] )
		end

		if #ctype.kids > 0 then table.insert( schg.kids, ctype ) end
		
		schg.kids = format.set_ver( schg.kids, body.obj, body.chg.verified )
		schg.kids = format.set_auth( schg.kids, body.obj, body.chg.authInfo )

		if #schg.kids > 0 then table.insert( add.kids, schg ) end
	end

	local resp, tmp_resp, rcode = req_res.req( body, epp )

	if body.tr_status == 'abort' then
		return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
	end

	if rcode and rcode == '1000' then
		local sql = 'UPDATE contacts SET %s upddate = NOW() WHERE id_registrars = ? AND contact_id = ?'

		local templ = { birthday = 'birthday', taxpayerNumbers = 'taxpayerNumbers', voice = 'voice', 
			fax = 'fax', email = 'email', passport = 'passport', verified = 'verified' }

		local postal = { 'intPostalInfo', 'locPostalInfo', 'legalInfo' }
			
		local set = ''

		if body.chg then
			for i,v in pairs( body.chg ) do 
				if templ[i] then
					set = set .. templ[i] .. ' = ' .. format.set_string_into_db( v ) .. ','
				end
			end

			for j,u in pairs( postal ) do
				if body.chg[u] then
					for i,v in pairs( body.chg[u] ) do
						set = set .. u .. '_' .. i .. ' =' .. format.set_string_into_db( v ) .. ','
					end
				end
			end
		end

		if body.status then
			set = set .. 'status = ' .. format.set_string_into_db( sql_status ) .. ','
		end

		--[[local postal = { 'intPostalInfo', 'locPostalInfo', 'legalInfo' }

		for j,u in pairs( postal ) do
			if body.chg[u] then
				for i,v in pairs( body.chg[u] ) do
					set = set .. u .. '_' .. i .. ' =' .. format.set_string_into_db( v ) .. ','
				end
			end
		end]]

		sql = string.format( sql, set )

		db.query( sql, body.regid, body.id )
	end

	return resp, rcode
end

--Создаем контакт
function contact.create( body )
	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]

	body.obj = 'contact'
	body.command = 'create'
	body.regid = select_registar.id

	local epp, add = format.epp_template( body.command, body.obj )

	add.kids = {}

	add.kids = format.set_objects_name_id( add.kids, body.obj, body.id )

	postal = {
		organization = { 'intPostalInfo', 'locPostalInfo', 'legalInfo' },
		person       = { 'intPostalInfo', 'locPostalInfo' }
	}
	strgs  = {
		organization = { 'taxpayerNumbers', 'voice', 'fax', 'email' },
		person       = { 'taxpayerNumbers', 'birthday', 'passport', 'voice', 'fax', 'email' }
	}

	local ctype = format.make_child_table( body.obj .. ':' .. body.type, nil, nil, 'Children are the flowers of life' )
		
	for _,v in pairs(postal[body.type]) do
		ctype.kids = format.set_postal_info( ctype.kids, body.obj, v, body[v], body.type )
	end

	for _,v in pairs(strgs[body.type]) do
		ctype.kids = format.set_string( ctype.kids, body.obj, v, body[v] )
	end
		
	table.insert( add.kids, ctype )

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

	if rcode and string.match( rcode, '1%d%d%d' ) then
		local sql = 'INSERT INTO contacts ( %s id_registrars, crdate, contact_id, verified ) VALUES (%s' .. tostring(body.regid) ..', NOW(),"' .. body.id .. '","unverified")'
		
		local templ = { birthday = 'birthday', taxpayerNumbers = 'taxpayerNumbers', voice = 'voice', 
			fax = 'fax', email = 'email', passport = 'passport', type = 'type' }
		--[[local templ = { 'taxpayerNumbers', 'birthday', 'passport', 'voice', 'fax', 'email' }

		if body.type == 'organization' then
			templ = { 'taxpayerNumbers', 'voice', 'fax', 'email' }
		end]]

		local var = ''  
		local val = ''
		for i,v in pairs( body ) do
			if templ[i] then
				var = var .. templ[i] .. ','
				val = val .. format.set_string_into_db( v ) .. ','
			end
		end

		local templ = { 'intPostalInfo', 'locPostalInfo', 'legalInfo' }
		
		for i,v in pairs( templ ) do 
			if body[v] then
				for j,u in pairs( body[v] ) do
					var = var .. v .. '_' .. j .. ','
					val = val .. format.set_string_into_db( u ) .. ','
				end	
			end
		end

		sql = string.format( sql, var, val )
		db.query( sql )
	end

	return resp, rcode, tmp_resp
end

--Информация о контакте
function contact.get( body )
	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]
	
	body.obj = 'contact'
	body.command = 'info'
	body.regid = select_registar.id

	local epp, add = format.epp_template( body.command, body.obj )

	add.kids = {}

	add.kids = format.set_objects_name_id( add.kids, body.obj, body.id )

	add.kids = format.set_auth( add.kids, body.obj, body.authInfo )

	local is_success, resp, tmp_resp, rcode = pcall( req_res.req, body, epp )

	if not is_success then resp = format.err( resp ) end

	if body.tr_status == 'abort' then
		return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
	end

	if tmp_resp and tablex.search( tmp_resp, 'infData' ) then

		resp[body.obj] = {}

		format.get_status( tmp_resp, resp[body.obj] )
		format.get_authInfo( tmp_resp, resp[body.obj] )
		format.get_verified( tmp_resp, resp[body.obj] )
		format.get_contact_type( tmp_resp, resp[body.obj] )

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
	end
	
	return resp, rcode, tmp_resp
end

--Копируем информацию о контакте в БД
function contact.copy( body )
	--Вытаскиваем инфу по контакту из реестра
	local info, icode = contact.get( body )

	if body.tr_status == 'abort' then
		return { result = { { code = '4444', msg = 'Пользовательская операция - ' .. body.clTRID .. ', ожидает выполнения' } } }
	end

	if icode ~= '1000' then
		body.tr_status = 'done'
		return { result = { { code = '4404', msg = 'Нет объекта', reason = 'Такого контакта нет в реестре' } } }
	end

	info = info.contact

	local sel = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]
	local id_registrars = sel.id

	--Смотрим есть ли данный контакт в БД, если есть, то апдейт иначе инсерт
	local sel = db.query( 'SELECT * FROM contacts WHERE contact_id = ? AND id_registrars = ?', body.id, body.regid )
	
	if #sel > 0 then
		local sql = 'UPDATE contacts SET %s WHERE id = "' .. sel[1].id .. '" AND id_registrars = "' .. id_registrars .. '"'

		local set = ''

		local templ = { birthday = 'birthday', taxpayerNumbers = 'taxpayerNumbers', voice = 'voice', 
			fax = 'fax', email = 'email', passport = 'passport', type = 'type', verified = 'verified' }

		for i,v in pairs( info ) do
			if templ[i] then
				set = set .. templ[i] .. ' = ' .. format.set_string_into_db( v ) .. ', '
			end
		end

		local templ = { 'intPostalInfo', 'locPostalInfo', 'legalInfo' }
		for i,v in pairs( templ ) do 
			if info[v] then
				for j,u in pairs( info[v] ) do
					set = set .. v .. '_' .. j .. ' = ' .. format.set_string_into_db( u ) .. ', '
				end	
			end
		end

		local templ = { crDate = 'crdate', upDate = 'upddate' }
		for i,v in pairs( templ ) do
			if info[i] then
				local time = {}
				time.year, time.month, time.day, time.hour, time.min, time.sec = string.match( info[i], "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)." )
				set = set .. v .. ' = "' .. os.date( '%Y-%m-%d %X', os.time( time ) + 18000 ) .. '", '
			end
		end

		if info.status then
			set = set .. 'status = ' .. format.set_string_into_db( info.status ) .. ', '
		end

		sql = string.format( sql, stringx.strip( set, ', ' ) )
		
		db.query( sql )
	else
		local sql = 'INSERT INTO contacts ( %s id_registrars,contact_id ) VALUES (%s' .. tostring(id_registrars) ..',"' .. body.id .. '")'
	
		local templ = { birthday = 'birthday', taxpayerNumbers = 'taxpayerNumbers', voice = 'voice', 
			fax = 'fax', email = 'email', passport = 'passport', type = 'type', verified = 'verified' }

		local var = ''  
		local val = ''
		for i,v in pairs( info ) do
			if templ[i] then
				var = var .. templ[i] .. ','
				val = val .. format.set_string_into_db( v ) .. ','
			end
		end

		local templ = { 'intPostalInfo', 'locPostalInfo', 'legalInfo' }
		for i,v in pairs( templ ) do 
			if info[v] then
				for j,u in pairs( info[v] ) do
					var = var .. v .. '_' .. j .. ','
					val = val .. format.set_string_into_db( u ) .. ','
				end	
			end
		end

		local templ = { crDate = 'crdate', upDate = 'upddate' }
		for i,v in pairs( templ ) do
			if info[i] then
				local time = {}
				time.year, time.month, time.day, time.hour, time.min, time.sec = string.match( info[i], "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)." )
				var = var .. v .. ','
				val = val .. '"' .. os.date( '%Y-%m-%d %X', os.time( time ) + 18000 ) .. '",'
			end
		end

		if info.status then
			var = var .. 'status,'
			val = val .. format.set_string_into_db( info.status ) .. ','
		end

		sql = string.format( sql, var, val )

		db.query( sql )
	end

	return { result = { { code = '4200', msg = 'Успех', reason = 'Объект контакт скопирован' } } }
end

return contact