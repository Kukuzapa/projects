-- Менеджер отпусков
local spec = require( 'api.spec' )

-- Валидация
require( "api.validate" )

adminControllerGenerated = {}
extended( adminControllerGenerated, adminControllerProgged )

-- get new vacations list
-- { "userid", "clname", "count", "page", "limit" }
function adminControllerGenerated:get_admin_new( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/admin/new"].get, params )
	if valid then
		return adminControllerProgged:get_admin_new( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- get current vacations list
-- { "userid", "clid", "clname", "count", "page", "limit" }
function adminControllerGenerated:get_admin_list( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/admin/list"].get, params )
	if valid then
		return adminControllerProgged:get_admin_list( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- set vacation comment
-- { "userid", "token" }
function adminControllerGenerated:post_admin_comment( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/admin/comment"].post, params )
	if valid then
		return adminControllerProgged:post_admin_comment( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- get vacation comments
-- { "userid", "vacid" }
function adminControllerGenerated:get_admin_comment( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/admin/comment"].get, params )
	if valid then
		return adminControllerProgged:get_admin_comment( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- get users list
-- { "userid", "clid", "clname", "token" }
function adminControllerGenerated:get_admin_users( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/admin/users"].get, params )
	if valid then
		return adminControllerProgged:get_admin_users( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- get vacation link
-- { "userid", "vacid" }
function adminControllerGenerated:get_admin_link( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/admin/link"].get, params )
	if valid then
		return adminControllerProgged:get_admin_link( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- set admins and competenses
-- { "userid", "token" }
function adminControllerGenerated:post_admin_user( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/admin/user"].post, params )
	if valid then
		return adminControllerProgged:post_admin_user( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- get count and vacation type
-- { "userid", "clid", "period" }
function adminControllerGenerated:get_admin_vacations( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/admin/vacations"].get, params )
	if valid then
		return adminControllerProgged:get_admin_vacations( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- vacation cross
-- { "userid", "vacid", "clid", "token" }
function adminControllerGenerated:get_admin_cross( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/admin/cross"].get, params )
	if valid then
		return adminControllerProgged:get_admin_cross( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- get log
-- { "userid", "vacid", "count", "page", "limit", "clname" }
function adminControllerGenerated:get_admin_log( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/admin/log"].get, params )
	if valid then
		return adminControllerProgged:get_admin_log( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- vacation decision
-- { "command", "userid", "token" }
function adminControllerGenerated:post_admin_vacation( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/admin/vacation/{command}"].post, params )
	if valid then
		return adminControllerProgged:post_admin_vacation( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- find client
-- { "userid", "clname", "token" }
function adminControllerGenerated:get_admin_find( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/admin/find"].get, params )
	if valid then
		return adminControllerProgged:get_admin_find( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- get old vacations list
-- { "userid", "clname", "count", "page", "limit" }
function adminControllerGenerated:get_admin_history( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/admin/history"].get, params )
	if valid then
		return adminControllerProgged:get_admin_history( validParams )
	else
		return validateResult ( false, true, err )
	end
end

