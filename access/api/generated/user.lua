-- Менеджер паролей

-- Валидация
require( "api.validate" )

userControllerGenerated = {}
extended( userControllerGenerated, userControllerProgged )

-- add user
-- {}
function userControllerGenerated:post_user_add( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/user/add"].post, params )
	if valid then
		return userControllerProgged:post_user_add( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- get user info
-- { "id", "user" }
function userControllerGenerated:get_user_get( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/user/get"].get, params )
	if valid then
		return userControllerProgged:get_user_get( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- user's roles
-- {}
function userControllerGenerated:post_user_role( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/user/role"].post, params )
	if valid then
		return userControllerProgged:post_user_role( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- remove user
-- {}
function userControllerGenerated:post_user_remove( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/user/remove"].post, params )
	if valid then
		return userControllerProgged:post_user_remove( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- user's node grants
-- {}
function userControllerGenerated:post_user_node( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/user/node"].post, params )
	if valid then
		return userControllerProgged:post_user_node( validParams )
	else
		return validateResult ( false, true, err )
	end
end

