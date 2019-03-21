-- ТЦИ АПИ 2

-- Отладка
local inspect = require( 'inspect' )
local config  = require("lapis.config").get()

local registrar = require 'module.registrar'
local format    = require 'module.format'

local util = require("lapis.util")
local db     = require("lapis.db")

registrarControllerProgged = {}
function registrarControllerProgged:new( params )
	local private = {}
	local public = {}

	-- Замена пароля регистратора на вход
	-- { "tld", "newPass" }
	-- Должно работать, но не работает.
	function registrarControllerProgged:post_registrar_password( params )
		local body = {}

		for i,v in pairs( config[params.tld] ) do
			body[i] = v
		end

		body.newPW = params.param.newPW

		body.clTRID = format.QC_insert( 'registrar', 'password', util.to_json( body ) )

		local is_success, fin = pcall( registrar.newPass, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )
		
		return { json = fin }
	end

	-- Добавляем/убираем ip адреса регистратора (?)
	-- { "tld" }
	function registrarControllerProgged:post_registrar_update( params )
		local body = {}

		for i,v in pairs( config[params.tld] ) do
			body[i] = v
		end

		body.ip = params.param.ip

		body.clTRID = format.QC_insert( 'registrar', 'update', util.to_json( body ) )

		local is_success, fin = pcall( registrar.update, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )
		
		return { json = fin }
	end

	-- Информация о регистраторе (?)
	-- { "tld" }
	function registrarControllerProgged:get_registrar_get( params )
		local body = {}

		for i,v in pairs( config[params.tld] ) do
			body[i] = v
		end
		
		body.clTRID = format.QC_insert( 'registrar', 'get', util.to_json( body ) )

		local is_success, fin = pcall( registrar.get, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )
		
		return { json = fin }
	end

	-- Команда проверки связи
	-- { "tld" }
	function registrarControllerProgged:get_registrar_hello( params )
		local body = {}

		for i,v in pairs( config[params.tld] ) do
			body[i] = v
		end

		body.clTRID = format.QC_insert( 'registrar', 'hello', util.to_json( body ) )

		local is_success, fin = pcall( registrar.hello, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )
		
		return { json = fin }
	end

	-- Статистика
	-- { "tld", "object", "pending" }
	function registrarControllerProgged:get_registrar_stat( params )
		local body = {}

		for i,v in pairs( config[params.tld] ) do
			body[i] = v
		end

		body.object = params.object
		body.pending = params.pending

		body.clTRID = format.QC_insert( 'registrar', 'stat', util.to_json( body ) )

		local is_success, fin = pcall( registrar.stat, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )
		
		return { json = fin }
	end

	-- Получение сообщений реестра (?)
	-- { "tld" }
	--Сделать и протестировать
	function registrarControllerProgged:get_registrar_poll( params )
		local body = {}
		
		for i,v in pairs( config[params.tld] ) do
			body[i] = v
		end

		body.clTRID = format.QC_insert( 'registrar', 'poll', util.to_json( body ) )

		local is_success, fin = pcall( registrar.poll, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID ) 

		return { json = fin }
	end

	-- Лимиты
	-- { "tld" }
	function registrarControllerProgged:get_registrar_limits( params )
		local body = {}

		for i,v in pairs( config[params.tld] ) do
			body[i] = v
		end

		body.clTRID = format.QC_insert( 'registrar', 'limits', util.to_json( body ) )

		local is_success, fin = pcall( registrar.limits, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )
		
		return { json = fin }
	end

	-- Биллинг
	-- { "tld", "billing" }
	function registrarControllerProgged:get_registrar_billing( params )
		local body = {}

		for i,v in pairs( config[params.tld] ) do
			body[i] = v
		end

		body.billing  = params.billing
		body.date     = params.date
		body.currency = params.currency
		body.period   = params.period

		body.clTRID = format.QC_insert( 'registrar', 'billing', util.to_json( body ) )

		local is_success, fin = pcall( registrar.billing, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )
		
		return { json = fin }
	end

	setmetatable( public, self )
	self.__index = self
	return public

end
