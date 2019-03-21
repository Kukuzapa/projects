-- ТЦИ АПИ 2
local spec = require( 'api.spec' )

-- Валидация
require( "api.validate" )

frontControllerGenerated = {}
extended( frontControllerGenerated, frontControllerProgged )

-- list of domain
-- { "column", "dir", "page", "domain" }
function frontControllerGenerated:get_list( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/list"].get, params )
	if valid then
		return frontControllerProgged:get_list( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Веб-интерфейс
-- { "query", "reg", "obj", "namid" }
function frontControllerGenerated:get_base( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/base"].get, params )
	if valid then
		return frontControllerProgged:get_base( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Сохраненные сообщения от ТЦИ
-- { "tld", "page" }
function frontControllerGenerated:get_poll( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/poll/{tld}"].get, params )
	if valid then
		return frontControllerProgged:get_poll( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- История
-- { "per_from", "per_to", "count", "clid" }
function frontControllerGenerated:get_history( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/history"].get, params )
	if valid then
		return frontControllerProgged:get_history( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Сохраненные сообщения от ТЦИ
-- { "tld", "page", "type" }
function frontControllerGenerated:get_getdata( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/getdata/{tld}"].get, params )
	if valid then
		return frontControllerProgged:get_getdata( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- sync domain
-- { "domain", "tld" }
function frontControllerGenerated:get_sync( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/sync/{tld}"].get, params )
	if valid then
		return frontControllerProgged:get_sync( validParams )
	else
		return validateResult ( false, true, err )
	end
end

