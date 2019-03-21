-- ТЦИ АПИ 2
local spec = require( 'api.spec' )

-- Валидация
require( "api.validate" )

panelControllerGenerated = {}
extended( panelControllerGenerated, panelControllerProgged )

-- panel domain create
-- { "username", "password" }
function panelControllerGenerated:post_panel_domain_create( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/panel/domain/create"].post, params )
	if valid then
		return panelControllerProgged:post_panel_domain_create( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- panel domain get transfer status
-- { "username", "password", "input_format", "input_data", "output_content_type" }
function panelControllerGenerated:get_panel_domain_get_transfer_status( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/panel/domain/get_transfer_status"].get, params )
	if valid then
		return panelControllerProgged:get_panel_domain_get_transfer_status( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- panel domain check
-- { "domain_name", "input_format", "input_data", "username", "password" }
function panelControllerGenerated:get_panel_domain_check( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/panel/domain/check"].get, params )
	if valid then
		return panelControllerProgged:get_panel_domain_check( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- panel domain set new authInfo
-- { "username", "password", "authinfo", "dname", "output_content_type" }
function panelControllerGenerated:post_panel_domain_set_new_authinfo( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/panel/domain/set_new_authinfo"].post, params )
	if valid then
		return panelControllerProgged:post_panel_domain_set_new_authinfo( validParams )
	else
		return validateResult ( false, true, err )
	end
end

