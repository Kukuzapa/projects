-- Менеджер паролей

-- Отладка
local inspect = require( 'inspect' )

local db     = require("lapis.db")

local helpers = require 'module.helpers'

findControllerProgged = {}
function findControllerProgged:new( params )
	local private = {}
	local public = {}

	-- find object
	-- { "id", "token", "value", "object" }
	function findControllerProgged:get_find( params )
		-- код писать тут
		local find = params

		--Проверка авторизации пользователя
		if not helpers.session( find.id, find.token ) then
			--return { json = { err = 'Вы не авторизированы' } }
		end
		----END----

		local fin = {}

		if find.object == 'node' then
			local sel = db.query( [[SELECT nodes.id,nodes.node,leaves.url FROM nodes 
										INNER JOIN leaves ON leaves.node = nodes.id
										WHERE nodes.node LIKE "%]] .. find.value .. [[%" OR leaves.url LIKE "%]] .. find.value .. [[%"]] )
			for i,v in pairs( sel ) do
				if helpers.check_grant( find.id, find.value, 'read' ) then
					if type( v.url ) == 'userdata' then
						sel[i].url = 'n/a'
					end
					table.insert( fin, v )
				end
			end
		end

		if find.object == 'user' then
			fin = db.query( 'SELECT user,id FROM users WHERE user LIKE "%' .. find.value .. '%"' )
		end

		if find.object == 'role' then
			fin = db.query( 'SELECT role,id FROM roles WHERE role LIKE "%' .. find.value .. '%"' )
		end
		
		return { json = fin }
	end

	setmetatable( public, self )
	self.__index = self
	return public

end
