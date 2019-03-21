-- ТЦИ АПИ 2
local spec = require( 'api.spec' )

-- Валидация
require( "api.validate" )

cronControllerGenerated = {}
extended( cronControllerGenerated, cronControllerProgged )

-- Запуск крона
-- {}
function cronControllerGenerated:get_cron( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/cron"].get, params )
	if valid then
		return cronControllerProgged:get_cron( validParams )
	else
		return validateResult ( false, true, err )
	end
end

