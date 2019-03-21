-- Менеджер паролей

-- Отладка
local inspect = require( 'inspect' )

require "api.progged.user"
require "api.generated.user"
local user = userControllerGenerated:new()
spec = require( 'api.spec' )
api_ver = spec.info.version or api_ver

require "api.progged.file"
require "api.generated.file"
local file = fileControllerGenerated:new()
local spec = require( 'api.spec' )
local api_ver = spec.info.version or api_ver

require "api.progged.role"
require "api.generated.role"
local role = roleControllerGenerated:new()
spec = require( 'api.spec' )
api_ver = spec.info.version or api_ver

require "api.progged.node"
require "api.generated.node"
local node = nodeControllerGenerated:new()
spec = require( 'api.spec' )
api_ver = spec.info.version or api_ver

require "api.progged.test"
require "api.generated.test"
local test = testControllerGenerated:new()
spec = require( 'api.spec' )
api_ver = spec.info.version or api_ver

require "api.progged.base"
require "api.generated.base"
local base = baseControllerGenerated:new()
spec = require( 'api.spec' )
api_ver = spec.info.version or api_ver

require "api.progged.front"
require "api.generated.front"
local front = frontControllerGenerated:new()
spec = require( 'api.spec' )
api_ver = spec.info.version or api_ver

require "api.progged.find"
require "api.generated.find"
local find = findControllerGenerated:new()
spec = require( 'api.spec' )
api_ver = spec.info.version or api_ver

-- add file
app:post( "/am/file/add", function( self )
	local ret = file:post_file_add( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- add file
app:post( "/am/file/remove", function( self )
	local ret = file:post_file_remove( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- file list
app:get( "/am/file/list", function( self )
	local ret = file:get_file_list( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- add user
app:post( "/am/user/add", function( self )
	local ret = user:post_user_add( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- user's roles
app:post( "/am/user/role", function( self )
	local ret = user:post_user_role( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- remove user
app:post( "/am/user/remove", function( self )
	local ret = user:post_user_remove( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- user's node grants
app:post( "/am/user/node", function( self )
	local ret = user:post_user_node( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- get user info
app:get( "/am/user/get", function( self )
	local ret = user:get_user_get( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- add node's grants to role
app:post( "/am/role/node", function( self )
	local ret = role:post_role_node( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- get roles list
app:get( "/am/role/list", function( self )
	local ret = role:get_role_list( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- get role info
app:get( "/am/role/get", function( self )
	local ret = role:get_role_get( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- add user into role
app:post( "/am/role/useradd", function( self )
	local ret = role:post_role_useradd( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- add role
app:post( "/am/role/add", function( self )
	local ret = role:post_role_add( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- remove role
app:post( "/am/role/remove", function( self )
	local ret = role:post_role_remove( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- remove user from role
app:post( "/am/role/userrem", function( self )
	local ret = role:post_role_userrem( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- add/rem manger to role
app:post( "/am/role/manager", function( self )
	local ret = role:post_role_manager( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- insert node
app:post( "/am/node/insert", function( self )
	local ret = node:post_node_insert( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- hello
app:get( "/am/hello", function( self )
	local ret = test:get_hello( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- get node id
app:get( "/am/base/node", function( self )
	local ret = base:get_base_node( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- get tree
app:get( "/am/base/tree", function( self )
	local ret = base:get_base_tree( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- get users list
app:get( "/am/base/user", function( self )
	local ret = base:get_base_user( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- get roles list
app:get( "/am/base/role", function( self )
	local ret = base:get_base_role( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- node user grant
app:post( "/am/node/user", function( self )
	local ret = node:post_node_user( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- update node
app:post( "/am/node/update", function( self )
	local ret = node:post_node_update( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- get node info
app:get( "/am/node/get", function( self )
	local ret = node:get_node_get( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- remove node
app:post( "/am/node/remove", function( self )
	local ret = node:post_node_remove( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- get tree
app:get( "/am/node/tree", function( self )
	local ret = node:get_node_tree( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- replace node
app:post( "/am/node/replace", function( self )
	local ret = node:post_node_replace( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- add node
app:post( "/am/node/add", function( self )
	local ret = node:post_node_add( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- node role grant
app:post( "/am/node/role", function( self )
	local ret = node:post_node_role( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- front
app:get( "/am/front", function( self )
	app:enable("etlua")
	app.layout = require "views.layout"
	--local ret = front:get_front( self )
	--if inspect( ret ) == "{}" then ret = { json = {} } end
	self.res.headers["Access-Control-Allow-Origin"] = "*"
	--return ret
	return { render = 'layout' }
end )

-- find object
app:get( "/am/find", function( self )
	local ret = find:get_find( self )
	if inspect( ret ) == "{}" then ret = { json = {} } end
	return ret
end )

-- ТЕСТ вью
--app:enable("etlua")
app:get("layout", "/(*)", function(self)
	app:enable("etlua")
	app.layout = require "views.layout"
	return { render = true }
end)