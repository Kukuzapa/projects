-- ТЦИ АПИ 2

-- Отладка
local inspect = require( 'inspect' )

require "api.progged.panel"
require "api.generated.panel"
local panel = panelControllerGenerated:new()
local spec = require( 'api.spec' )
local api_ver = spec.info.version or api_ver

require "api.progged.domain"
require "api.generated.domain"
local domain = domainControllerGenerated:new()
spec = require( 'api.spec' )
api_ver = spec.info.version or api_ver

require "api.progged.registrar"
require "api.generated.registrar"
local registrar = registrarControllerGenerated:new()
spec = require( 'api.spec' )
api_ver = spec.info.version or api_ver

require "api.progged.contact"
require "api.generated.contact"
local contact = contactControllerGenerated:new()
spec = require( 'api.spec' )
api_ver = spec.info.version or api_ver

require "api.progged.front"
require "api.generated.front"
local front = frontControllerGenerated:new()
spec = require( 'api.spec' )
api_ver = spec.info.version or api_ver

require "api.progged.cron"
require "api.generated.cron"
local cron = cronControllerGenerated:new()
spec = require( 'api.spec' )
api_ver = spec.info.version or api_ver

-- Сохраненные сообщения от ТЦИ
app:get( "/api/v".. api_ver .. "/getdata/:tld", function( self )
	local ret = front:get_getdata( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Сохраненные сообщения от ТЦИ
app:get( "/api/v".. api_ver .. "/poll/:tld", function( self )
	local ret = front:get_poll( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Проверяем занятьсть имени (?)
app:get( "/api/v".. api_ver .. "/domain/check", function( self )
	local ret = domain:get_domain_check( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Удаляем домен
app:post( "/api/v".. api_ver .. "/domain/delete", function( self )
	local ret = domain:post_domain_delete( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Продление домена
app:post( "/api/v".. api_ver .. "/domain/renew", function( self )
	local ret = domain:post_domain_renew( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Информация о домене (?)
app:get( "/api/v".. api_ver .. "/domain/get", function( self )
	local ret = domain:get_domain_get( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Создаем домен
app:post( "/api/v".. api_ver .. "/domain/create", function( self )
	local ret = domain:post_domain_create( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Обновление данных из реестра (?!)
app:get( "/api/v".. api_ver .. "/domain/copy", function( self )
	local ret = domain:get_domain_copy( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Передача домена
app:post( "/api/v".. api_ver .. "/domain/transfer/:transfer", function( self )
	local ret = domain:post_domain_transfer( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Обновление домена
app:post( "/api/v".. api_ver .. "/domain/update", function( self )
	local ret = domain:post_domain_update( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Замена пароля регистратора на вход
app:post( "/api/v".. api_ver .. "/registrar/password/:tld", function( self )
	local ret = registrar:post_registrar_password( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Биллинг
app:get( "/api/v".. api_ver .. "/registrar/billing/:tld", function( self )
	local ret = registrar:get_registrar_billing( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Добавляем/убираем ip адреса регистратора (?)
app:post( "/api/v".. api_ver .. "/registrar/update/:tld", function( self )
	local ret = registrar:post_registrar_update( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Информация о регистраторе (?)
app:get( "/api/v".. api_ver .. "/registrar/get/:tld", function( self )
	local ret = registrar:get_registrar_get( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Команда проверки связи
app:get( "/api/v".. api_ver .. "/registrar/hello/:tld", function( self )
	local ret = registrar:get_registrar_hello( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Статистика
app:get( "/api/v".. api_ver .. "/registrar/stat/:tld", function( self )
	local ret = registrar:get_registrar_stat( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Получение сообщений реестра (?)
app:get( "/api/v".. api_ver .. "/registrar/poll/:tld", function( self )
	local ret = registrar:get_registrar_poll( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Лимиты
app:get( "/api/v".. api_ver .. "/registrar/limits/:tld", function( self )
	local ret = registrar:get_registrar_limits( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Удаляем contact (?)
app:post( "/api/v".. api_ver .. "/contact/delete/:tld", function( self )
	local ret = contact:post_contact_delete( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Информация о контакте (?)
app:get( "/api/v".. api_ver .. "/contact/get/:tld", function( self )
	local ret = contact:get_contact_get( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Create contact person
app:post( "/api/v".. api_ver .. "/contact/create/:tld", function( self )
	local ret = contact:post_contact_create( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Обновление данных из реестра (?!)
app:get( "/api/v".. api_ver .. "/contact/copy/:tld", function( self )
	local ret = contact:get_contact_copy( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Update contact person
app:post( "/api/v".. api_ver .. "/contact/update/:tld", function( self )
	local ret = contact:post_contact_update( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Проверяем занятьсть ID (?)
app:get( "/api/v".. api_ver .. "/contact/check/:tld", function( self )
	local ret = contact:get_contact_check( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Веб-интерфейс
app:get( "/api/v".. api_ver .. "/base", function( self )
	local ret = front:get_base( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- list of domain
app:get( "/api/v".. api_ver .. "/list", function( self )
	local ret = front:get_list( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- list of domain
--app:get( "/api/v".. api_ver .. "/sync", function( self )
--	local ret = front:get_sync( self )
--	if inspect( ret ) == "{}" then ret = { json = {} } end
--	return ret
--end )

-- sync domain
app:get( "/api/v".. api_ver .. "/sync/:tld", function( self )
	local ret = front:get_sync( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- История
app:get( "/api/v".. api_ver .. "/history", function( self )
	local ret = front:get_history( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- Веб-интерфейс
--[[app:match( "/api/v".. api_ver .. "/front", function( self )
	app:enable("etlua")
	app.layout = require "views.layout"
	--local ret = front:get_front( self )
	--if inspect( ret ) == "{}" then ret = { json = {} } end
	self.res.headers["Access-Control-Allow-Origin"] = "*"
	--return ret
	return { render = 'layout' }
end )]]

-- Запуск крона
app:get( "/api/v".. api_ver .. "/cron", function( self )
	local ret = cron:get_cron( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- panel domain get transfer status
app:get( "/api/v".. api_ver .. "/panel/domain/get_transfer_status", function( self )
	local ret = panel:get_panel_domain_get_transfer_status( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- panel domain set new authInfo
app:post( "/api/v".. api_ver .. "/panel/domain/set_new_authinfo", function( self )
	local ret = panel:post_panel_domain_set_new_authinfo( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- panel domain create
app:post( "/api/v".. api_ver .. "/panel/domain/create", function( self )
	local ret = panel:post_panel_domain_create( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- panel domain check
app:get( "/api/v".. api_ver .. "/panel/domain/check", function( self )
	local ret = panel:get_panel_domain_check( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

app:match( "/(*)", function( self )
	app:enable("etlua")
	app.layout = require "views.layout"
	--local ret = front:get_front( self )
	--if inspect( ret ) == "{}" then ret = { json = {} } end
	self.res.headers["Access-Control-Allow-Origin"] = "*"
	--return ret
	return { render = 'layout' }
end )

