-- Менеджер отпусков
local spec = require( 'api.spec' )
-- Валидация
require( "api.validate" )

baseControllerGenerated = {}
extended( baseControllerGenerated, baseControllerProgged )

-- get count and vacation type
-- { "userid", "clid" }
function baseControllerGenerated:get_vacations( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/vacations"].get, params )
	if valid then
		return baseControllerProgged:get_vacations( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- get users list
-- { "userid", "clid", "token" }
function baseControllerGenerated:get_users( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/users"].get, params )
	if valid then
		return baseControllerProgged:get_users( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- set vacation comment
-- { "userid", "token" }
function baseControllerGenerated:post_comment( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/comment"].post, params )
	if valid then
		return baseControllerProgged:post_comment( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- get vacation comments
-- { "userid", "vacid", "token" }
function baseControllerGenerated:get_comment( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/comment"].get, params )
	if valid then
		return baseControllerProgged:get_comment( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- get log
-- { "userid", "vacid", "token", "count", "page", "limit" }
function baseControllerGenerated:get_log( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/log"].get, params )
	if valid then
		return baseControllerProgged:get_log( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- find client
-- { "userid", "clname", "token" }
function baseControllerGenerated:get_find( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/find"].get, params )
	if valid then
		return baseControllerProgged:get_find( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- vacation cross
-- { "userid", "vacid", "clid", "token" }
function baseControllerGenerated:get_cross( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/cross"].get, params )
	if valid then
		return baseControllerProgged:get_cross( validParams )
	else
		return validateResult ( false, true, err )
	end
end

