local tablex  = require 'pl.tablex'
local format  = require 'module.format'
local db      = require("lapis.db")
local req_res = require 'module.req_res'
local stringx = require 'pl.stringx'

local host = {}

function host.check( body )
	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]

	body.obj = 'host'
	body.command = 'check'
	body.regid = select_registar.id

	local epp, add = format.epp_template( body.command, body.obj )

	add.kids = {}

	add.kids = format.set_objects_name_id( add.kids, body.obj, body.name )

	local resp, tmp_resp, rcode = req_res.req( body, epp )

	if tmp_resp and tablex.search( tmp_resp, 'chkData' ) then
		resp[body.command] = {}
		format.get_check( tmp_resp, resp[body.command], 'name' )
	end

	return resp, rcode
end

function host.get( body )
	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]

	body.obj = 'host'
	body.command = 'info'
	body.regid = select_registar.id

	local epp, add = format.epp_template( body.command, body.obj )

	add.kids = {}

	add.kids = format.set_objects_name_id( add.kids, body.obj, body.name )

	local resp, tmp_resp, rcode = req_res.req( body, epp )

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

function host.create( body )
	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]

	body.obj = 'host'
	body.command = 'create'
	body.regid = select_registar.id

	local epp, add = format.epp_template( body.command, body.obj )

	add.kids = {}

	add.kids = format.set_objects_name_id( add.kids, body.obj, body.name )

	if type( body.ip ) == 'table' and tablex.size( body.ip ) > 0 then
		add.kids = format.set_ip( add.kids, body.ip, body.obj )
	end
	
	local resp, tmp_resp, rcode = req_res.req( body, epp )

	if tmp_resp and tablex.search( tmp_resp, 'creData' ) then
		resp[body.command] = {}

		local template = { 'name', 'id', 'crDate', 'exDate' }

		for _,v in pairs( template ) do
			format.get_string( tmp_resp, v, resp[body.command] )
		end
	end

	return resp, rcode, tmp_resp
end

function host.update( body )
	local select_registar = db.query( 'SELECT * FROM registrars WHERE registrar = ?' ,body.reg )[1]

	body.obj = 'host'
	body.command = 'update'
	body.regid = select_registar.id

	local info_body = tablex.copy( body )
	info_body.command = 'info'
	local old, ocode = host.get( info_body )

	if not string.match( ocode, '1%d%d%d' ) then
		local fin = { err = 'Нет такого объекта' }
		return fin
	end

	local old_ip = {} 
	
	if old.host.v4 then
		for _,v in pairs(old.host.v4) do table.insert( old_ip, v ) end
	end

	if old.host.v6 then
		for _,v in pairs(old.host.v6) do table.insert( old_ip, v ) end
	end

	local ip,iip
	local tmp = {}
	tmp.add = {}
	tmp.rem = {}
	tmp.chg = {}
	
	if body.ip then
		ip,iip = format.add_or_rem_status( body.ip, old_ip )
	end

	if ip then
		if #ip.add > 0 then
			tmp.add.ip = ip.add
		end
		if #ip.rem > 0 then
			tmp.rem.ip = ip.rem
		end
	end
	
	for i,v in pairs( tmp ) do
		if tablex.size( v ) > 0 then
			body[i] = v
		end
	end

	local epp, add = format.epp_template( body.command, body.obj )

	add.kids = {}

	add.kids = format.set_objects_name_id( add.kids, body.obj, body.name )

	if tmp.add then
		local sadd = format.make_child_table( body.obj .. ':add', nil, nil, 'Children are the flowers of life' )
		sadd.kids = format.set_ip( sadd.kids, tmp.add.ip, body.obj )
		if #sadd.kids > 0 then table.insert( add.kids, sadd ) end
	end
	if tmp.rem then
		local sadd = format.make_child_table( body.obj .. ':rem', nil, nil, 'Children are the flowers of life' )
		sadd.kids = format.set_ip( sadd.kids, tmp.rem.ip, body.obj )
		if #sadd.kids > 0 then table.insert( add.kids, sadd ) end
	end

	local resp, tmp_resp, rcode = req_res.req( body, epp )

	return rcode,iip
end

return host