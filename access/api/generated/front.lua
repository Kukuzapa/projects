-- Менеджер паролей

-- Валидация
require( "api.validate" )

frontControllerGenerated = {}
extended( frontControllerGenerated, frontControllerProgged )

-- front
-- {}
function frontControllerGenerated:get_front( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/front"].get, params )
	if valid then
		return frontControllerProgged:get_front( validParams )
	else
		return validateResult ( false, true, err )
	end
end

