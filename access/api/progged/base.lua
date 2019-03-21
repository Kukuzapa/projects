-- Менеджер паролей
local db = require("lapis.db")
local tablex = require 'pl.tablex'
local helpers = require 'module.helpers'
-- Отладка
local inspect = require( 'inspect' )

baseControllerProgged = {}
function baseControllerProgged:new( params )
	local private = {}
	local public = {}

	-- get tree
	-- { "id" }
	function baseControllerProgged:get_base_tree( params )
		-- код писать тут

		
		local fin = {} local tree local tmp = {}

		--Прверяем является ли пользователь админом	и строим дерево, админ - все, нет - по правам
		if helpers.check_admin( params.id ) then
			tree = db.query([[
				WITH RECURSIVE get_tree AS
					(SELECT id,node,pid,1 lvl FROM nodes WHERE pid IS NULL
						UNION ALL
						SELECT n.id, n.node, n.pid, lvl+1 FROM nodes n INNER JOIN get_tree g ON n.pid = g.id)
						SELECT * FROM get_tree]])
		else
			tree = db.query([[
				WITH RECURSIVE get_tree AS
					(SELECT id,node,pid,1 lvl FROM nodes WHERE pid IS NULL
						UNION ALL
						SELECT n.id, n.node, n.pid, lvl+1 FROM nodes n INNER JOIN get_tree g ON n.pid = g.id)
						SELECT * FROM get_tree WHERE id IN
					(SELECT nodes.id FROM nodes
						INNER JOIN acl_grants_users ON acl_grants_users.node = nodes.id
						INNER JOIN users ON acl_grants_users.user = users.id
						INNER JOIN grants ON acl_grants_users.grnt = grants.id
						WHERE grants.grnt = 'pass' AND users.id = ?
					UNION
					SELECT nodes.id FROM nodes
						INNER JOIN acl_grants_roles ON acl_grants_roles.node = nodes.id
						INNER JOIN grants ON acl_grants_roles.grnt = grants.id 
						INNER JOIN roles ON acl_grants_roles.role = roles.id 
						INNER JOIN roles_users ON roles_users.role = roles.id
						INNER JOIN users ON roles_users.user = users.id
						WHERE grants.grnt = 'pass' AND users.id = ?)]], params.id, params.id )
		end
		----END----
		local function func( tree, node )
			if node.pid == tree.key then
				local q = {}
				q.key = node.id
				q.title = node.node
				q.children = {}
				table.insert(tree.children,q)
			else
				for i,v in pairs(tree.children) do
					func(v,node)
				end
			end
		end
		
		for i,v in pairs(tree) do
			if type(v.pid)=='userdata' then
				tmp.key = v.id
				tmp.title = v.node
				tmp.children = {}
				table.insert(fin,tmp)
			else
				func(fin[1],v)
			end
		end

		--ngx.say(inspect(fin))


		return {
			json = fin 
			--[[{
				
    					{title = "Node 1", key = "1"},
    					{title = "Folder 2", key = "2", children = {
      						{title = "Node 2.1", key = "3"},
      						{title = "Node 2.2", key = "4"}
    					}}
  					
			}]]
		}
	end

	-- get users list
	-- {}
	function baseControllerProgged:get_base_user( params )
		local fin = db.query( 'SELECT * FROM users' )

		return { json = fin }
	end

	-- get node id
	-- { "node" }???????????????????????????????
	function baseControllerProgged:get_base_node( params )
		-- код писать тут
		local fin = db.query( 'SELECT * FROM nodes' )

		return {
			json = fin
		}
	end

	-- get roles list
	-- {}
	function baseControllerProgged:get_base_role( params )

		local fin = {}
		
		if helpers.check_admin( params.id ) then
			local sel = db.query( 'SELECT * FROM roles' )

			for i,v in pairs( sel ) do
				table.insert( fin, { text = v.role } )
			end
		else
			
		end

		--local fin = db.query( 'SELECT * FROM roles' )

		return { json = fin }
	end

	setmetatable( public, self )
	self.__index = self
	return public

end
