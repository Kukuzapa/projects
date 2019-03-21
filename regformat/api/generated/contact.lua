-- ТЦИ АПИ 2
local spec = require( 'api.spec' )

-- Валидация
require( "api.validate" )

contactControllerGenerated = {}
extended( contactControllerGenerated, contactControllerProgged )

-- Информация о контакте (?)
-- { "tld", "id", "authInfo" }
function contactControllerGenerated:get_contact_get( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/contact/get/{tld}"].get, params )
	if valid then
		return contactControllerProgged:get_contact_get( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Обновление данных из реестра (?!)
-- { "tld", "id", "authInfo" }
function contactControllerGenerated:get_contact_copy( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/contact/copy/{tld}"].get, params )
	if valid then
		return contactControllerProgged:get_contact_copy( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Create contact person
-- { "tld" }
function contactControllerGenerated:post_contact_create( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/contact/create/{tld}"].post, params )
	if valid then
		return contactControllerProgged:post_contact_create( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Update contact person
-- { "tld" }
function contactControllerGenerated:post_contact_update( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/contact/update/{tld}"].post, params )
	if valid then
		return contactControllerProgged:post_contact_update( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Удаляем contact (?)
-- { "tld", "id" }
function contactControllerGenerated:post_contact_delete( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/contact/delete/{tld}"].post, params )
	if valid then
		return contactControllerProgged:post_contact_delete( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- Проверяем занятьсть ID (?)
-- { "tld", "id" }
function contactControllerGenerated:get_contact_check( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/contact/check/{tld}"].get, params )
	if valid then
		return contactControllerProgged:get_contact_check( validParams )
	else
		return validateResult ( false, true, err )
	end
end

