-- Менеджер паролей

-- Валидация
require( "api.validate" )

nodeControllerGenerated = {}
extended( nodeControllerGenerated, nodeControllerProgged )

-- node user grant
-- {}
function nodeControllerGenerated:post_node_user( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/node/user"].post, params )
	if valid then
		return nodeControllerProgged:post_node_user( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- update node
-- {}
function nodeControllerGenerated:post_node_update( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/node/update"].post, params )
	if valid then
		return nodeControllerProgged:post_node_update( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- get node info
-- { "id", "node" }
function nodeControllerGenerated:get_node_get( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/node/get"].get, params )
	if valid then
		return nodeControllerProgged:get_node_get( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- remove node
-- {}
function nodeControllerGenerated:post_node_remove( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/node/remove"].post, params )
	if valid then
		return nodeControllerProgged:post_node_remove( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- get tree
-- { "id" }
function nodeControllerGenerated:get_node_tree( params )
	local valid, validParams, err = validateParams( "get", spec.paths["/node/tree"].get, params )
	if valid then
		return nodeControllerProgged:get_node_tree( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- replace node
-- {}
function nodeControllerGenerated:post_node_replace( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/node/replace"].post, params )
	if valid then
		return nodeControllerProgged:post_node_replace( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- add node
-- {}
function nodeControllerGenerated:post_node_add( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/node/add"].post, params )
	if valid then
		return nodeControllerProgged:post_node_add( validParams )
	else
		return validateResult ( false, true, err )
	end
end

-- node role grant
-- {}
function nodeControllerGenerated:post_node_role( params )
	local valid, validParams, err = validateParams( "post", spec.paths["/node/role"].post, params )
	if valid then
		return nodeControllerProgged:post_node_role( validParams )
	else
		return validateResult ( false, true, err )
	end
end

