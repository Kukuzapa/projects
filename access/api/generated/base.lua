-- Менеджер паролей

-- Валидация
require( "api.validate" )

baseControllerGenerated = {}
extended( baseControllerGenerated, baseControllerProgged )

-- get node id
-- { "id", "grnt" }
function baseControllerGenerated:get_base_node( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/base/node"].get, params )
	if valid then
		return baseControllerProgged:get_base_node( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- get tree
-- { "id" }
function baseControllerGenerated:get_base_tree( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/base/tree"].get, params )
	if valid then
		return baseControllerProgged:get_base_tree( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- get users list
-- {}
function baseControllerGenerated:get_base_user( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/base/user"].get, params )
	if valid then
		return baseControllerProgged:get_base_user( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- get roles list
-- {}
function baseControllerGenerated:get_base_role( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/base/role"].get, params )
	if valid then
		return baseControllerProgged:get_base_role( validParams )
	else
		return validateResult ( false, true, err )
	end
end

