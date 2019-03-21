-- ТЦИ АПИ 2

-- Отладка
local inspect = require( 'inspect' )

local config = require("lapis.config").get()
local db     = require("lapis.db")
local util   = require("lapis.util")

--Сторонние модули
local stringx = require 'pl.stringx'
local tablex  = require 'pl.tablex'


--local simcom = require 'module.similar_commands'

--Модули Апи
--local host    = require 'module.host'
local domain    = require 'module.domain'
local format    = require 'module.format'
local contact   = require 'module.contact'
local registrar = require 'module.registrar'

cronControllerProgged = {}
function cronControllerProgged:new( params )
	local private = {}
	local public = {}

	-- Запуск крона
	-- {}
	function cronControllerProgged:get_cron( params )
		local select_queue = db.query( 'SELECT * FROM queueClient WHERE status = "abort"' )

		local test = {}
		for i,v in pairs( select_queue ) do
			local body = util.from_json( v.request )
			body.clTRID = v.id

			local fin, is_success
			
			if v.object == 'domain' then
				--fin = domain[v.command]( body )
				is_success, fin = pcall( domain[v.command], body )
				if not is_success then fin = format.err( fin ) end
			end

			if v.object == 'contact' then
				--fin = contact[v.command]( body )
				is_success, fin = pcall( contact[v.command], body )
				if not is_success then fin = format.err( fin ) end
			end

			if v.object == 'registrar' then
				--fin = registrar[v.command]( body )
				is_success, fin = pcall( registrar[v.command], body )
				if not is_success then fin = format.err( fin ) end
			end
			
			db.query( 'UPDATE queueClient SET response = ?, status = ?, date_cron = NOW() WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )
			table.insert(test,fin)
		end

		return { json = test }
	end

	setmetatable( public, self )
	self.__index = self
	return public

end
