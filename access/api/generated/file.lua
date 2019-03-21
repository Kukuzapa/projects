-- Менеджер паролей
local spec = require( 'api.spec' )

-- Валидация
require( "api.validate" )

fileControllerGenerated = {}
extended( fileControllerGenerated, fileControllerProgged )

-- add file
-- {}
function fileControllerGenerated:post_file_add( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/file/add"].post, params )
	if valid then
		return fileControllerProgged:post_file_add( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- add file
-- {}
function fileControllerGenerated:post_file_remove( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/file/remove"].post, params )
	if valid then
		return fileControllerProgged:post_file_remove( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- file list
-- { "id", "node" }
function fileControllerGenerated:get_file_list( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/file/list"].get, params )
	if valid then
		return fileControllerProgged:get_file_list( validParams )
	else
		return validateResult ( false, true, err )
	end
end

