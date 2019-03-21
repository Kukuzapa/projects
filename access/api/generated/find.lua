-- Менеджер паролей

-- Валидация
require( "api.validate" )

findControllerGenerated = {}
extended( findControllerGenerated, findControllerProgged )

-- find object
-- { "id", "token", "value", "object" }
function findControllerGenerated:get_find( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/find"].get, params )
	if valid then
		return findControllerProgged:get_find( validParams )
	else
		return validateResult ( false, true, err )
	end
end

