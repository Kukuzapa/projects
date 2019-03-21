-- Менеджер паролей
local spec = require( 'api.spec' )

-- Валидация
require( "api.validate" )

roleControllerGenerated = {}
extended( roleControllerGenerated, roleControllerProgged )

-- get role info
-- { "id", "role", "token" }
function roleControllerGenerated:get_role_get( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/role/get"].get, params )
	if valid then
		return roleControllerProgged:get_role_get( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- add/rem manger to role
-- {}
function roleControllerGenerated:post_role_manager( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/role/manager"].post, params )
	if valid then
		return roleControllerProgged:post_role_manager( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- remove user from role
-- {}
function roleControllerGenerated:post_role_userrem( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/role/userrem"].post, params )
	if valid then
		return roleControllerProgged:post_role_userrem( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- add user into role
-- {}
function roleControllerGenerated:post_role_useradd( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/role/useradd"].post, params )
	if valid then
		return roleControllerProgged:post_role_useradd( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- add role
-- {}
function roleControllerGenerated:post_role_add( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/role/add"].post, params )
	if valid then
		return roleControllerProgged:post_role_add( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- add node's grants to role
-- {}
function roleControllerGenerated:post_role_node( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/role/node"].post, params )
	if valid then
		return roleControllerProgged:post_role_node( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- remove role
-- {}
function roleControllerGenerated:post_role_remove( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/role/remove"].post, params )
	if valid then
		return roleControllerProgged:post_role_remove( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- get roles list
-- { "id" }
function roleControllerGenerated:get_role_list( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/role/list"].get, params )
	if valid then
		return roleControllerProgged:get_role_list( validParams )
	else
		return validateResult ( false, true, err )
	end
end

