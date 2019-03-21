-- Менеджер паролей

-- Валидация
require( "api.validate" )

testControllerGenerated = {}
extended( testControllerGenerated, testControllerProgged )

-- hello
-- {}
function testControllerGenerated:get_hello( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/hello"].get, params )
	if valid then
		return testControllerProgged:get_hello( validParams )
	else
		return validateResult ( false, true, err )
	end
end

