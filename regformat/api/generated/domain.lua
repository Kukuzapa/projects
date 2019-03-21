-- ТЦИ АПИ 2
local spec = require( 'api.spec' )

-- Валидация
require( "api.validate" )

domainControllerGenerated = {}
extended( domainControllerGenerated, domainControllerProgged )

-- Проверяем занятьсть имени (?)
-- { "name" }
function domainControllerGenerated:get_domain_check( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/domain/check"].get, params )
	if valid then
		return domainControllerProgged:get_domain_check( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Удаляем домен
-- {}
function domainControllerGenerated:post_domain_delete( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/domain/delete"].post, params )
	if valid then
		return domainControllerProgged:post_domain_delete( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Продление домена
-- {}
function domainControllerGenerated:post_domain_renew( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/domain/renew"].post, params )
	if valid then
		return domainControllerProgged:post_domain_renew( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Обновление домена
-- {}
function domainControllerGenerated:post_domain_update( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/domain/update"].post, params )
	if valid then
		return domainControllerProgged:post_domain_update( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Информация о домене (?)
-- { "name", "authInfo" }
function domainControllerGenerated:get_domain_get( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/domain/get"].get, params )
	if valid then
		return domainControllerProgged:get_domain_get( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Создаем домен
-- {}
function domainControllerGenerated:post_domain_create( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/domain/create"].post, params )
	if valid then
		return domainControllerProgged:post_domain_create( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Обновление данных из реестра (?!)
-- { "name", "authInfo" }
function domainControllerGenerated:get_domain_copy( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/domain/copy"].get, params )
	if valid then
		return domainControllerProgged:get_domain_copy( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Передача домена
-- { "transfer" }
function domainControllerGenerated:post_domain_transfer( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/domain/transfer/{transfer}"].post, params )
	if valid then
		return domainControllerProgged:post_domain_transfer( validParams )
	else
		return validateResult ( false, true, err )
	end
end

