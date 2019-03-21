-- Менеджер паролей

-- Отладка
local inspect = require( 'inspect' )

frontControllerProgged = {}
function frontControllerProgged:new( params )
	local private = {}
	local public = {}

	-- front
	-- {}
	function frontControllerProgged:get_front( params )
		-- код писать тут
		return {
			json = {
				success = true,
				error = false,
				message = 'NYI; DEBUG: ' .. inspect( params )
			}
		}
	end

	setmetatable( public, self )
	self.__index = self
	return public

end
