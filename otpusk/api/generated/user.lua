-- Менеджер отпусков
local spec = require( 'api.spec' )

-- Валидация
require( "api.validate" )

userControllerGenerated = {}
extended( userControllerGenerated, userControllerProgged )

-- create vacation
-- { "command", "userid" }
function userControllerGenerated:post_user_vacation( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/user/vacation/{command}"].post, params )
	if valid then
		return userControllerProgged:post_user_vacation( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- get count and vacation type
-- { "userid", "clid", "period" }
function userControllerGenerated:get_user_vacations( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/user/vacations"].get, params )
	if valid then
		return userControllerProgged:get_user_vacations( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- cancel vacation
-- { "userid", "token" }
function userControllerGenerated:post_user_vacation_cancel( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/user/vacation/cancel"].post, params )
	if valid then
		return userControllerProgged:post_user_vacation_cancel( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- vacation list
-- { "userid", "token" }
function userControllerGenerated:get_user_list( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/user/list"].get, params )
	if valid then
		return userControllerProgged:get_user_list( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- login
-- { "token", "name", "userid", "email" }
function userControllerGenerated:get_user_login( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/user/login"].get, params )
	if valid then
		return userControllerProgged:get_user_login( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- get user info
-- {}
function userControllerGenerated:get_user_get( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/user/get"].get, params )
	if valid then
		return userControllerProgged:get_user_get( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- vacation list
-- { "userid", "token" }
function userControllerGenerated:get_user_history( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/user/history"].get, params )
	if valid then
		return userControllerProgged:get_user_history( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- set vacation comment
-- { "userid", "token" }
function userControllerGenerated:post_user_comment( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/user/comment"].post, params )
	if valid then
		return userControllerProgged:post_user_comment( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- get vacation comments
-- { "userid", "vacid" }
function userControllerGenerated:get_user_comment( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/user/comment"].get, params )
	if valid then
		return userControllerProgged:get_user_comment( validParams )
	else
		return validateResult ( false, true, err )
	end
end

