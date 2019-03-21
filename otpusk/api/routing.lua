-- Менеджер отпусков

-- Отладка
local inspect = require( 'inspect' )

require "api.progged.base"
require "api.generated.base"
local base = baseControllerGenerated:new()
spec = require( 'api.spec' )
api_ver = spec.info.version or api_ver

require "api.progged.user"
require "api.generated.user"
local user = userControllerGenerated:new()
spec = require( 'api.spec' )
api_ver = spec.info.version or api_ver

require "api.progged.admin"
require "api.generated.admin"
local admin = adminControllerGenerated:new()
spec = require( 'api.spec' )
api_ver = spec.info.version or api_ver

-- create vacation
app:post( "/vm/user/vacation/:command", function( self )
	local ret = user:post_user_vacation( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- get vacation link
app:get( "/vm/admin/link", function( self )
	local ret = admin:get_admin_link( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- cancel vacation
app:post( "/vm/user/vacation/cancel", function( self )
	local ret = user:post_user_vacation_cancel( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- vacation list
app:get( "/vm/user/list", function( self )
	local ret = user:get_user_list( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- login
app:get( "/vm/user/login", function( self )
	local ret = user:get_user_login( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- get user info
app:get( "/vm/user/get", function( self )
	local ret = user:get_user_get( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- vacation list
app:get( "/vm/user/history", function( self )
	local ret = user:get_user_history( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- set vacation comment
app:post( "/vm/user/comment", function( self )
	local ret = user:post_user_comment( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- get vacation comments
app:get( "/vm/user/comment", function( self )
	local ret = user:get_user_comment( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- find client
app:get( "/vm/admin/find", function( self )
	local ret = admin:get_admin_find( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- get current vacations list
app:get( "/vm/admin/list", function( self )
	local ret = admin:get_admin_list( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- set vacation comment
app:post( "/vm/admin/comment", function( self )
	local ret = admin:post_admin_comment( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- get vacation comments
app:get( "/vm/admin/comment", function( self )
	local ret = admin:get_admin_comment( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- get users list
app:get( "/vm/admin/users", function( self )
	local ret = admin:get_admin_users( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- set admins and competenses
app:post( "/vm/admin/user", function( self )
	local ret = admin:post_admin_user( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- get count and vacation type
app:get( "/vm/admin/vacations", function( self )
	local ret = admin:get_admin_vacations( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- vacation cross
app:get( "/vm/admin/cross", function( self )
	local ret = admin:get_admin_cross( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- get new vacations list
app:get( "/vm/admin/new", function( self )
	local ret = admin:get_admin_new( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- vacation decision
app:post( "/vm/admin/vacation/:command", function( self )
	local ret = admin:post_admin_vacation( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- get log
app:get( "/vm/admin/log", function( self )
	local ret = admin:get_admin_log( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- get old vacations list
app:get( "/vm/admin/history", function( self )
	local ret = admin:get_admin_history( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- get count and vacation type
app:get( "/vm/user/vacations", function( self )
	local ret = user:get_user_vacations( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

app:match("layout", "/(*)", function(self)
	app:enable("etlua")
	app.layout = require "views.layout"
	return { render = true }
end)