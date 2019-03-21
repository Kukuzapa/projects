-- ТЦИ АПИ 2

-- Отладка
local inspect = require( 'inspect' )

local config = require("lapis.config").get()
local db     = require("lapis.db")

local uuid    = require("uuid")
local format  = require 'module.format'
local contact = require 'module.contact'
local stringx = require 'pl.stringx'
local tablex  = require 'pl.tablex'

local util = require("lapis.util")

contactControllerProgged = {}
function contactControllerProgged:new( params )
	local private = {}
	local public = {}

	-- Удаляем contact (?)
	-- { "tld", "id" }
	function contactControllerProgged:post_contact_delete( params, req )
		local body = {}

		for i,v in pairs( config[params.tld] ) do
			body[i] = v
		end

		body.id = params.id or params.param.id

		body.clTRID = format.QC_insert( 'contact', 'delete', util.to_json( body ) )

		local is_success, fin = pcall( contact.delete, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )
		
		return { json = fin }
	end

	-- Информация о контакте (?)
	-- { "tld", "id", "authInfo" }
	function contactControllerProgged:get_contact_get( params, req )
		local body = {}

		for i,v in pairs( config[params.tld] ) do
			body[i] = v
		end

		body.id = params.id
		body.authInfo = params.authInfo

		body.clTRID = format.QC_insert( 'contact', 'get', util.to_json( body ) )

		local is_success, fin = pcall( contact.get, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )
		
		return { json = fin }
	end

	-- Create contact person
	-- { "tld" }
	function contactControllerProgged:post_contact_create( params )
		local body = {}

		for i,v in pairs( config[params.tld] ) do
			body[i] = v
		end

		body.birthday        = params.param.birthday
		body.taxpayerNumbers = params.param.taxpayerNumbers
		body.voice           = params.param.voice
		body.fax             = params.param.fax
		body.email           = params.param.email
		body.passport        = params.param.passport
	
		if params.param.int_name or params.param.int_org then
			body.intPostalInfo = {
				name    = params.param.int_name,
				org     = params.param.int_org,
				address = params.param.int_address
			}
		end
	
		body.locPostalInfo = {
			name    = params.param.name,
			org     = params.param.org,
			address = params.param.address
		}
	
		if params.param.leg_address then
			body.legalInfo = {
				address = params.param.leg_address
			}
			body.type = 'organization'
		else
			body.type = 'person'
		end

		uuid.seed(os.time())

		body.id = string.gsub( uuid.new(), '-', '' )

		body.clTRID = format.QC_insert( 'contact', 'create', util.to_json( body ) )

		local is_success, fin = pcall( contact.create, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )

		return { json = fin }
	end

	-- Обновление данных из реестра (?!)
	-- { "id", "authInfo" }
	function contactControllerProgged:get_contact_copy( params )
		local body = {}

		for i,v in pairs( config[params.tld] ) do
			body[i] = v
		end

		body.id = params.id
		body.authInfo = params.authInfo

		body.clTRID = format.QC_insert( 'contact', 'copy', util.to_json( body ) )
		
		local is_success, fin = pcall( contact.copy, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )

		return { json = fin }
	end

	-- Update contact person
	-- { "tld", "id" }
	function contactControllerProgged:post_contact_update( params )
		local body = {}

		for i,v in pairs( config[params.tld] ) do
			body[i] = v
		end

		local upd = params.param

		body.status = upd.status
		body.id = upd.id

		local chg = {
			birthday        = upd.birthday,
			taxpayerNumbers = upd.taxpayerNumbers,
			voice           = upd.voice,
			fax             = upd.fax,
			email           = upd.email,
			passport        = upd.passport,
			verified        = upd.verified,
			authInfo        = upd.authInfo
		}

		if upd.int_name or upd.int_org or upd.int_address then
			chg.intPostalInfo = {
				name    = upd.int_name,
				org     = upd.int_org,
				address = upd.int_address
			}
		end
	
		if upd.name or upd.org or upd.address then
			chg.locPostalInfo = {
				name    = upd.name,
				org     = upd.org,
				address = upd.address
			}
		end
	
		if upd.leg_address then
			chg.legalInfo = {
				address = upd.leg_address
			}
		end

		if tablex.size( chg ) > 0 then
			body.chg = chg
		end

		body.clTRID = format.QC_insert( 'contact', 'update', util.to_json( body ) )

		local is_success, fin = pcall( contact.update, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )

		return { json = fin }
	end

	-- Проверяем занятьсть ID (?)
	-- { "tld", "id" }
	function contactControllerProgged:get_contact_check( params )
		local body = {}

		for i,v in pairs( config[params.tld] ) do
			body[i] = v
		end

		body.id = params.id

		body.clTRID = format.QC_insert( 'contact', 'update', util.to_json( body ) )

		local is_success, fin = pcall( contact.check, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )
		
		return { json = fin }
	end

	setmetatable( public, self )
	self.__index = self
	return public

end
