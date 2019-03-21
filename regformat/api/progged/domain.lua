-- ТЦИ АПИ 2

-- Отладка
local inspect = require( 'inspect' )

--Модули ляписа
local config = require("lapis.config").get()
local db     = require("lapis.db")
local util   = require("lapis.util")

--Сторонние модули
local stringx = require 'pl.stringx'
local tablex  = require 'pl.tablex'

--Модули Апи
local domain  = require 'module.domain'
local format  = require 'module.format'

local function set_tld( str )
	local st = 'rf'
	local templ = { 'ru', 'RU', 'Ru', 'rU' }
	for i,v in pairs( templ ) do
		if stringx.rfind( str, v ) then st = 'ru' end
	end
	return st
end

domainControllerProgged = {}
function domainControllerProgged:new( params )
	local private = {}
	local public = {}

	-- Проверяем занятьсть имени (?)
	-- { "name" }
	function domainControllerProgged:get_domain_check( params )
		local body = {}

		for i,v in pairs( config[set_tld( params.name )] ) do
			body[i] = v
		end
		
		body.name = params.name
		
		--ngx.say( util.to_json( body ) )

		body.clTRID = format.QC_insert( 'domain', 'check', util.to_json( body ) )

		local is_success, fin = pcall( domain.check, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )
		
		return { json = fin }
	end

	-- Удаляем домен
	-- { "name" }
	function domainControllerProgged:post_domain_delete( params )
		local body = {}

		local crt = params.param

		for i,v in pairs( config[set_tld( crt.name )] ) do
			body[i] = v
		end

		body.name = crt.name

		--ngx.say( util.to_json( body ) )

		body.clTRID = format.QC_insert( 'domain', 'delete', util.to_json( body ) )

		local is_success, fin = pcall( domain.delete, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )

		return { json = fin }
	end

	-- Обновление данных из реестра (?!)
	-- { "name", "authInfo" }
	function domainControllerProgged:get_domain_copy( params )
		local body = {}

		for i,v in pairs( config[set_tld( params.name )] ) do
			body[i] = v
		end

		body.name = params.name

		--ngx.say( util.to_json( body ) )

		body.clTRID = format.QC_insert( 'domain', 'copy', util.to_json( body ) )

		local is_success, fin = pcall( domain.copy, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )

		return { json = fin }
	end

	-- Продление домена
	-- { "name", "curExpDate" }
	function domainControllerProgged:post_domain_renew( params )
		local body = {}

		local crt = params.param

		for i,v in pairs( config[set_tld( crt.name )] ) do
			body[i] = v
		end

		body.name = crt.name
		body.curExpDate = crt.curExpDate

		--ngx.say( util.to_json( body ) )

		body.clTRID = format.QC_insert( 'domain', 'renew', util.to_json( body ) )

		local is_success, fin = pcall( domain.renew, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )

		return { json = fin }
	end

	-- Передача домена
	-- { "transfer", "name" }
	function domainControllerProgged:post_domain_transfer( params )
		local body = {}

		local crt = params.param

		for i,v in pairs( config[set_tld( crt.name )] ) do
			body[i] = v
		end

		body.name = crt.name
		body.authInfo = crt.authInfo
		body.transfer = params.transfer

		--ngx.say( util.to_json( body ) )

		body.clTRID = format.QC_insert( 'domain', 'transfer', util.to_json( body ) )

		local is_success, fin = pcall( domain.transfer, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )

		return { json = fin }
	end

	-- Обновление домена
	-- { "name" }
	function domainControllerProgged:post_domain_update( params )
		local body = {}
		
		body.nss = {}

		local crt = params.param

		for i,v in pairs( config[set_tld( crt.name )] ) do
			body[i] = v
		end

		body.name        = crt.name
		body.description = crt.description
		body.registrant  = crt.registrant
		body.authInfo    = crt.authInfo
		body.status      = crt.status

		if crt.ns then
			for i,v in pairs( crt.ns ) do
				
				body.nss[i] = true

				if type( v ) == 'string' and v:len() > 0 and stringx.count( i, '.' .. body.name ) > 0 then
					body.nss[i] = stringx.split( v, ' ' )
				end
			end
		end

		--if tablex.size( body.nss ) == 0 then body.nss = nil end

		body.clTRID, block = format.QC_insert( 'domain', 'update', util.to_json( body ), body.name )

		local is_success, fin

		if block then
			body.tr_status = 'block'

			fin = { result = { { code = '4213', msg = 'Объект ожидает выполнения другой операции', reason = str } } }
		else
			is_success, fin = pcall( domain.update, body )
			
			if not is_success then fin = format.err( fin ) end
		end
		
		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )

		return { json = fin }
	end

	-- Создаем домен
	-- { "name" }
	function domainControllerProgged:post_domain_create( params )
		local body = {}
		body.nss   = {}
		body.subnss = {}

		local crt = params.param
		
		--print(inspect(params.param))

		for i,v in pairs( config[set_tld( crt.name )] ) do
			body[i] = v
		end

		body.name        = crt.name
		body.description = crt.description
		body.registrant  = crt.registrant
		body.authInfo    = crt.authInfo

		if crt.ns then
			for i,v in pairs( crt.ns ) do
				
				table.insert( body.nss, i )

				if type( v ) == 'string' and v:len() > 0 and stringx.count( i, '.' .. body.name ) > 0 then
					body.subnss[i] = stringx.split( v, ' ' )
				end
			end
		end
		
		if tablex.size( body.nss ) == 0 then body.nss = nil end
		if tablex.size( body.subnss ) == 0 then body.subnss = nil end

		body.clTRID = format.QC_insert( 'domain', 'create', util.to_json( body ) )

		local is_success, fin = pcall( domain.create, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )

		return { json = fin }
	end

	-- Информация о домене (?)
	-- { "name", "authInfo" }
	function domainControllerProgged:get_domain_get( params )
		local body = {}

		for i,v in pairs( config[set_tld( params.name )] ) do
			body[i] = v
		end

		body.name = params.name
		body.authInfo = params.authInfo
		
		--ngx.say( util.to_json( body ) )

		body.clTRID = format.QC_insert( 'domain', 'get', util.to_json( body ) )

		local is_success, fin = pcall( domain.get, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )
		
		return { json = fin }
	end

	setmetatable( public, self )
	self.__index = self
	return public

end
