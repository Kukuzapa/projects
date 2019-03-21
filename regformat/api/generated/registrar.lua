-- ТЦИ АПИ 2
local spec = require( 'api.spec' )

-- Валидация
require( "api.validate" )

registrarControllerGenerated = {}
extended( registrarControllerGenerated, registrarControllerProgged )

-- Замена пароля регистратора на вход
-- { "tld", "newPass" }
function registrarControllerGenerated:post_registrar_password( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/registrar/password/{tld}"].post, params )
	if valid then
		return registrarControllerProgged:post_registrar_password( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Биллинг
-- { "tld", "billing", "currency", "date", "period" }
function registrarControllerGenerated:get_registrar_billing( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/registrar/billing/{tld}"].get, params )
	if valid then
		return registrarControllerProgged:get_registrar_billing( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Добавляем/убираем ip адреса регистратора (?)
-- { "tld" }
function registrarControllerGenerated:post_registrar_update( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/registrar/update/{tld}"].post, params )
	if valid then
		return registrarControllerProgged:post_registrar_update( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Информация о регистраторе (?)
-- { "tld" }
function registrarControllerGenerated:get_registrar_get( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/registrar/get/{tld}"].get, params )
	if valid then
		return registrarControllerProgged:get_registrar_get( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Команда проверки связи
-- { "tld" }
function registrarControllerGenerated:get_registrar_hello( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/registrar/hello/{tld}"].get, params )
	if valid then
		return registrarControllerProgged:get_registrar_hello( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Статистика
-- { "tld", "object", "pending" }
function registrarControllerGenerated:get_registrar_stat( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/registrar/stat/{tld}"].get, params )
	if valid then
		return registrarControllerProgged:get_registrar_stat( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Получение сообщений реестра (?)
-- { "tld" }
function registrarControllerGenerated:get_registrar_poll( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/registrar/poll/{tld}"].get, params )
	if valid then
		return registrarControllerProgged:get_registrar_poll( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Лимиты
-- { "tld" }
function registrarControllerGenerated:get_registrar_limits( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/registrar/limits/{tld}"].get, params )
	if valid then
		return registrarControllerProgged:get_registrar_limits( validParams )
	else
		return validateResult ( false, true, err )
	end
end

