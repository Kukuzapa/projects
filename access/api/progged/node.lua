-- Менеджер паролей
local db = require("lapis.db")
local tablex = require 'pl.tablex'
local stringx = require 'pl.stringx'
local helpers = require 'module.helpers'

-- Отладка
local inspect = require( 'inspect' )

nodeControllerProgged = {}
function nodeControllerProgged:new( params )
	local private = {}
	local public = {}

	-- node user grant
	-- {}
	function nodeControllerProgged:post_node_user( params )
		local node_user = params.param

		--Проверка авторизации пользователя
		--if not helpers.session( node_user.id, node_user.token ) then
		--	return { json = { err = 'Вы не авторизированы' } }
		--end
		----END----

		--Проверка права выставлять разрешения на узел
		if not helpers.check_grant( node_user.id, node_user.node, 'access' ) then
			return { json = { err = 'Вы не можете давать права доступа на данный узел' } }
		end
		----END----

		--Проверка на наличие такого узла
		local check_node = db.query( 'SELECT * FROM nodes WHERE node = ?', node_user.node )

		if tablex.size( check_node ) == 0 then
			return { json = { err = 'Такого узла не существует' } }
		end
		----END----

		--Проверка существования пользователей
		for i,v in pairs( node_user.user ) do
			local check_user = db.query( 'SELECT * FROM users WHERE user = ?', i )

			if tablex.size( check_user ) == 0 then
				return { json = { err = 'Указанный пользователь не существует' } }
			end
		end
		----END----

		--Обрабатываем массив пользователей
		for i,v in pairs( node_user.user ) do

			local user_id = db.query( 'SELECT id FROM users WHERE user = ?', i )[1].id
			
			if v:len() == 0 then
				helpers.remove_grants( 'users', user_id, node_user.node )
			--Иначе, массив разрешений не пустой
			else
				helpers.set_grants( 'users', user_id, node_user.node, v )
			end

		end
		----END----

		return { json = { success = 'Разрешения для пользователей изменены' } }
	end

	-- node role grant
	-- {}
	function nodeControllerProgged:post_node_role( params )
		local node_role = params.param

		--Проверка авторизации пользователя
		--if not helpers.session( node_role.id, node_role.token ) then
		--	return { json = { err = 'Вы не авторизированы' } }
		--end
		----END----

		--Проверка права выставлять разрешения на узел
		if not helpers.check_grant( node_role.id, node_role.node, 'access' ) then
			return { json = { err = 'Вы не можете давать права доступа на данный узел' } }
		end
		----END----

		--if not next( node_role.role ) then
		--	return { json = { err = 'Нет новых разрешений' } }
		--end

		--Проверка на наличие такого узла
		local check_node = db.query( 'SELECT * FROM nodes WHERE node = ?', node_role.node )

		if tablex.size( check_node ) == 0 then
			return { json = { err = 'Такого узла не существует' } }
		end
		----END----

		--Проверка существования роли
		for i,v in pairs( node_role.role ) do
			local check_role = db.query( 'SELECT * FROM roles WHERE role = ?', i )

			if tablex.size( check_role ) == 0 then
				return { json = { err = 'Указанная роль не существует' } }
			end
		end
		----END----

		

		--Обрабатываем массив ролей
		for i,v in pairs( node_role.role ) do
			
			local role_id = db.query( 'SELECT id FROM roles WHERE role = ?', i )[1].id
			
			if v:len() == 0 then
				helpers.remove_grants( 'roles', role_id, node_role.node )
			--Иначе, массив разрешений не пустой
			else
				helpers.set_grants( 'roles', role_id, node_role.node, v )
			end
		end

		return { json = { success = 'Права успешно назначены' } }
	end

	-- update node
	-- {}
	function nodeControllerProgged:post_node_update( params )
		local node_update = params.param

		--Проверка авторизации пользователя
		if not helpers.session( node_update.id, node_update.token ) then
			return { json = { err = 'Вы не авторизированы' } }
		end
		----END----

		if not helpers.check_grant( node_update.id, node_update.node, 'update' ) then
			return { json = { err = 'Вы не можете менять данный узел' } }
		end

		local templ = { 'comment','password','email','url','files', }

		--local var = '' local val = ''
		local set = ''

		local sql = 'UPDATE leaves SET%s WHERE node = (SELECT id FROM nodes WHERE node = ?)'

		for i,v in pairs( templ ) do
			if ( node_update[v] ) then
				set = set .. ', ' .. v .. '="' .. node_update[v] .. '"'
			end
		end

		set = stringx.strip(set,',')

		sql = string.format( sql, set )
		--ngx.say(sql)
		if set:len() > 0 then
			db.query( sql, node_update.node )
		end

		return { json = { success = 'Узел обновлен' } }
	end

	-- get node info
	-- { "id", "node" }
	function nodeControllerProgged:get_node_get( params )
		local node_get = params

		--Проверка авторизации пользователя
		--if not helpers.session( node_get.id, node_get.token ) then
		--	return { json = { err = 'Вы не авторизированы' } }
		--end
		----END----

		--Проверка прав на выполнение операции
		if not helpers.check_grant( node_get.id, node_get.node, 'read' ) then
			return { json = { err = 'Вы не можете читать данный узел' } }
		end
		----END----

		local fin = {}
		fin.info  = {}
		fin.users = {}
		fin.roles = {}
		fin.grnts = {}
		fin.main  = {}

		--fin.lists = {}

		--fin.lists.users = {}
		--fin.lists.roles = {}

		local leaves = db.query( 'SELECT * FROM leaves WHERE node = (SELECT id FROM nodes WHERE node = ?)', node_get.node )
		if #leaves == 0 then
			db.query( 'INSERT INTO leaves (node) VALUES ((SELECT id FROM nodes WHERE node = ?))', node_get.node )
			leaves = db.query( 'SELECT * FROM leaves WHERE node = (SELECT id FROM nodes WHERE node = ?)', node_get.node )
		end

		--ngx.say( inspect(leaves))
		local main = db.query('SELECT * FROM nodes WHERE node = ?',node_get.node)
		for i,v in pairs( main[1] ) do
			fin.main[i] = v
		end

		for i,v in pairs( leaves[1] ) do
			if type( v ) ~= 'userdata' then
				fin.info[i] = v
			end
		end

		local users = db.query( [[
							SELECT users.user, grants.grnt FROM acl_grants_users 
								INNER JOIN users ON acl_grants_users.user = users.id
								INNER JOIN nodes ON acl_grants_users.node = nodes.id
								INNER JOIN grants ON acl_grants_users.grnt = grants.id
								WHERE nodes.node = ?]], node_get.node )
		for i,v in pairs( users ) do
			if not rawget( fin.users, v.user ) then
				--ngx.say(i)
				fin.users[v.user] = {}
			end
			--fin.users[i] = v.grnt
			table.insert( fin.users[v.user], v.grnt )
		end

		local roles = db.query( [[
							SELECT roles.role, grants.grnt FROM acl_grants_roles 
								INNER JOIN roles ON acl_grants_roles.role = roles.id
								INNER JOIN nodes ON acl_grants_roles.node = nodes.id
								INNER JOIN grants ON acl_grants_roles.grnt = grants.id
								WHERE nodes.node = ?]], node_get.node )
		for i,v in pairs( roles ) do
			if not rawget( fin.roles, v.role ) then
				--ngx.say(i)
				fin.roles[v.role] = {}
			end
			--fin.users[i] = v.grnt
			table.insert( fin.roles[v.role], v.grnt )
		end

		local grants = db.query( [[
							SELECT users.id,'admins' FROM roles_users
										INNER JOIN users ON roles_users.user = users.id
										INNER JOIN roles ON roles_users.role = roles.id
										WHERE users.userid = ? AND roles.role = 'admins'
							UNION
							SELECT users.id,grants.grnt FROM nodes
										INNER JOIN acl_grants_users ON acl_grants_users.node = nodes.id
										INNER JOIN users ON acl_grants_users.user = users.id
										INNER JOIN grants ON acl_grants_users.grnt = grants.id
										WHERE users.userid = ? AND nodes.node = ?
							UNION
							SELECT users.id,grants.grnt FROM nodes
										INNER JOIN acl_grants_roles ON acl_grants_roles.node = nodes.id
										INNER JOIN grants ON acl_grants_roles.grnt = grants.id 
										INNER JOIN roles ON acl_grants_roles.role = roles.id 
										INNER JOIN roles_users ON roles_users.role = roles.id
										INNER JOIN users ON roles_users.user = users.id
										WHERE users.userid = ? AND nodes.node = ?]], node_get.id, node_get.id, node_get.node, node_get.id, node_get.node )

		for i,v in pairs( grants ) do
			--if not rawget( fin.roles, v.role ) then
				--ngx.say(i)
			--	fin.roles[v.role] = {}
			--end
			--fin.users[i] = v.grnt
			table.insert( fin.grnts, v.admins )
		end

		local lu = db.query( 'SELECT * FROM users' )

		for i,v in pairs( lu ) do
			if not fin.users[v.user] then
				fin.users[v.user] = {}
			end
			--table.insert( fin.lists.users, v.user )
		end

		local lr = db.query( 'SELECT * FROM roles' )

		for i,v in pairs( lr ) do
			if not fin.roles[v.role] then
				fin.roles[v.role] = {}
			end
			--table.insert( fin.lists.roles, v.role )
		end

		--ngx.say( inspect(users))		
		return { json = fin }
	end

	-- remove node
	-- {}
	function nodeControllerProgged:post_node_remove( params )
		local node_remove = params.param

		--Проверка авторизации пользователя
		--if not helpers.session( node_remove.id, node_remove.token ) then
		--	return { json = { err = 'Вы не авторизированы' } }
		--end
		----END----

		--Проверка прав на выполнение операции
		if not helpers.check_grant( node_remove.id, node_remove.node, 'access' ) then
			return { json = { err = 'Вы не можете удалить данный узел' } }
		end
		----END----

		--Проверка на наличие такого узла
		local check_node = db.query( 'SELECT * FROM nodes WHERE node = ?', node_remove.node )

		if tablex.size( check_node ) == 0 then
			return { json = { err = 'Такого узла не существует' } }
		end
		----END----

		--Удаляем узел
		db.query( 'DELETE FROM nodes WHERE node = ?', node_remove.node )
		----END----

		return { json = { success = 'Узел ' .. node_remove.node .. ' успешно удален' } }
	end

	-- get tree
	-- { "id" }
	function nodeControllerProgged:get_node_tree( params )

		local fin = {} local tree local tmp = {} local isadmin = false

		--Прверяем является ли пользователь админом	и строим дерево, админ - все, нет - по правам
		if helpers.check_admin( params.id ) then
			isadmin = true
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
						WHERE grants.grnt = 'pass' AND users.userid = ?
					UNION
					SELECT nodes.id FROM nodes
						INNER JOIN acl_grants_roles ON acl_grants_roles.node = nodes.id
						INNER JOIN grants ON acl_grants_roles.grnt = grants.id 
						INNER JOIN roles ON acl_grants_roles.role = roles.id 
						INNER JOIN roles_users ON roles_users.role = roles.id
						INNER JOIN users ON roles_users.user = users.id
						WHERE grants.grnt = 'pass' AND users.userid = ?)]], params.id, params.id )
		end
		----END----
		local function func( tree, node )
			--[[if node.pid == tree.key then
				local q = {}
				q.key = node.id
				q.title = node.node
				q.children = {}
				table.insert(tree.children,q)
			else
				for i,v in pairs(tree.children) do
					func(v,node)
				end
			end]]
			if node.pid == tree.id then
				local q = {}
				q.id = node.id
				q.text = node.node
				q.children = {}
				table.insert(tree.children,q)
			else
				for i,v in pairs(tree.children) do
					func(v,node)
				end
			end
		end
		
		for i,v in pairs(tree) do
			--[[if type(v.pid)=='userdata' then
				tmp.key = v.id
				tmp.title = v.node
				tmp.children = {}
				table.insert(fin,tmp)
			else
				func(fin[1],v)
			end]]
			if type(v.pid)=='userdata' then
				tmp.id = v.id
				tmp.text = v.node
				tmp.children = {}
				table.insert(fin,tmp)
			else
				func(fin[1],v)
			end
		end

		local function pre_fin( tbl )

			tbl.data = {}

			if isadmin then
				tbl.data.grants = { 'pass', 'read', 'delete', 'insert', 'replace', 'access', 'update' }
			else
				tbl.data.grants = {}
				local node_grants = db.query( [[SELECT u.user, n.node, g.grnt FROM acl_grants_users acu
					INNER JOIN nodes n ON acu.node = n.id
					INNER JOIN grants g ON acu.grnt = g.id
					INNER JOIN users u ON acu.user = u.id
					WHERE n.node = ? AND u.userid = ?
					UNION
					SELECT u.user, n.node, g.grnt FROM acl_grants_roles acr
					INNER JOIN nodes n ON acr.node = n.id
					INNER JOIN grants g ON acr.grnt = g.id
					INNER JOIN roles r ON acr.role = r.id
					INNER JOIN roles_users ru ON r.id = ru.role
					INNER JOIN users u ON ru.user = u.id
					WHERE n.node = ? AND u.userid = ?]],
					tbl.text, params.id, tbl.text, params.id )
				for i,v in pairs( node_grants ) do
					table.insert( tbl.data.grants, v.grnt )
				end
			end

			if #tbl.children == 0 then
				tbl.children = nil
				return
			else
				for i,v in pairs( tbl.children ) do
					pre_fin( v )
				end
			end
		end

		pre_fin( fin[1] )

		return { json = fin }
	end

	-- replace node
	-- TODO Слишком некрасивые запросы - переделать и сократить
	-- {}
	function nodeControllerProgged:post_node_replace( params )
		local node_replace = params.param

		--Проверка авторизации пользователя
		--if not helpers.session( node_replace.id, node_replace.token ) then
		--	return { json = { err = 'Вы не авторизированы' } }
		--end
		----END----

		--Проверка прав на выполнение операции
		if not helpers.check_grant( node_replace.id, node_replace.node, 'replace' ) then
			return { json = { err = 'Вы не можете переместить данный узел отсюда' } }
		end
		----END----

		--Проверка возможности вставить узел в родителя
		if not helpers.check_grant( node_replace.id, node_replace.prnt, 'insert' ) then
			return { json = { err = 'У вас нет прав на добавление потомков в узел ' .. node_replace.prnt } }
		end
		----END----

		--Проверка на наличие такого узла
		local check_node = db.query( 'SELECT * FROM nodes WHERE node = ?', node_replace.node )

		if tablex.size( check_node ) == 0 then
			return { json = { err = 'Такого узла не существует' } }
		end
		----END----

		if node_replace.node == node_replace.prnt then
			return { json = { err = 'Данная операция недопустима' } }
		end

		--Проверка существования нового родителя
		local check_parent = db.query( 'SELECT * FROM nodes WHERE node = ?', node_replace.prnt )

		if tablex.size( check_parent ) == 0 then
			return { json = { err = 'Такого родителя не существует' } }
		end

		local new_parent_id = db.query( 'SELECT id FROM nodes WHERE node = ?', node_replace.prnt )[1].id

		--Получим теущего родителя
		local current_parent = db.query( 'SELECT pid FROM nodes WHERE node = ?', node_replace.node )[1].pid

		if type( current_parent ) == 'userdata' then
			return { json = { err = 'Корневой узел нельзя переносить' } }
		end

		--TODO обработка если узел уже в данном отце
		----END----

		local users = db.query( 'SELECT * FROM acl_grants_users WHERE node = (SELECT id FROM nodes WHERE node = ?)', node_replace.node )
		for i,v in pairs( users ) do
			users[i] = v.user
		end
		--ngx.say(users)

		local roles = db.query( 'SELECT * FROM acl_grants_roles WHERE node = (SELECT id FROM nodes WHERE node = ?)', node_replace.node )
		for i,v in pairs( roles ) do
			roles[i] = v.role
		end

		local old_parents = helpers.get_parents( node_replace.node )
		--Переносим
		db.query( 'UPDATE nodes SET pid = ? WHERE node = ?', new_parent_id, node_replace.node )
		----END----

		--Получим новое дерево от цели до корня и дадим связанным ролям и юзерам минимальные разрешения, если еще нет
		local new_parents = helpers.get_parents( node_replace.node, 'node' )

		for _,v in pairs( new_parents ) do
			for _,u in pairs( users ) do
				local check = helpers.get_grants( 'users', u, v )
				if #check == 0 then
					db.query( [[INSERT INTO acl_grants_users (user,node,grnt) VALUES (?,
									(SELECT id FROM nodes WHERE node = ?),(SELECT id FROM grants WHERE grnt = ?))]], u, v, 'pass' )
				end
			end
			for _,u in pairs( roles ) do
				local check = helpers.get_grants( 'roles', u, v )
				if #check == 0 then
					db.query( [[INSERT INTO acl_grants_roles (role,node,grnt) VALUES (?,
									(SELECT id FROM nodes WHERE node = ?),(SELECT id FROM grants WHERE grnt = ?))]], u, v, 'pass' )
				end
			end
		end
		----END----

		--Снесем ненужные разрешения старого дерева
		local pass = db.query( 'SELECT * FROM grants WHERE grnt = "pass"' )[1].id

		for _,v in pairs( old_parents ) do
			if type( v.pid ) ~= 'userdata' then
				for _,u in pairs( users ) do
					local sql1 = db.query( 'SELECT * FROM acl_grants_users WHERE user = ? AND node IN (SELECT id FROM nodes WHERE pid = ?)', u, v.id )
					local sql2 = db.query( 'SELECT * FROM acl_grants_users WHERE user = ? AND node = ?', u, v.id )

					--local pass = db.query( 'SELECT * FROM grants WHERE grnt = "pass"' )[1].id

					if #sql1 == 0 and #sql2 == 1 and sql2[1].grnt == pass then
						db.query( 'DELETE FROM acl_grants_users WHERE node = ? AND user = ?', v.id, u )
					else
						break
					end
				end
				for _,u in pairs( roles ) do
					local sql1 = db.query( 'SELECT * FROM acl_grants_roles WHERE role = ? AND node IN (SELECT id FROM nodes WHERE pid = ?)', u, v.id )
					local sql2 = db.query( 'SELECT * FROM acl_grants_roles WHERE role = ? AND node = ?', u, v.id )

					--local pass = db.query( 'SELECT * FROM grants WHERE grnt = "pass"' )[1].id

					if #sql1 == 0 and #sql2 == 1 and sql2[1].grnt == pass then
						db.query( 'DELETE FROM acl_grants_roles WHERE node = ? AND role = ?', v.id, u )
					else
						break
					end
				end
			end
		end
		----END----

		return { json = { success = 'Узел ' .. node_replace.node .. ' успешно перенесен в ' .. node_replace.prnt, parents = parents } }
	end

	-- add node
	-- {}
	function nodeControllerProgged:post_node_add( params )
		local node_add = params.param

		--ngx.say(inspect(params.param))

		--Проверка авторизации пользователя
		--if not helpers.session( node_add.id, node_add.token ) then
		--	return { json = { err = 'Вы не авторизированы' } }
		--end
		----END----

		--Проверка прав на выполнение операции
		if not helpers.check_grant( node_add.id, node_add.prnt, 'insert' ) then
			return { json = { err = 'Вы не можете создать дочерний узел в данном узле' } }
		end
		----END----

		--Проверка на наличие такого узла
		local check_node = db.query( 'SELECT * FROM nodes WHERE node = ?', node_add.chld )

		if tablex.size( check_node ) > 0 then
			return { json = { err = 'Узел с таким именем уже существует' } }
		end
		----END----

		--Создание узла и его листа
		local prnt_id = db.query( 'SELECT id FROM nodes WHERE node = ?', node_add.prnt )[1].id

		db.query( 'INSERT INTO nodes (pid,node) VALUES (?,?)', prnt_id, node_add.chld )

		local leaves = { 'comment', 'files', 'url', 'password', 'email' }

		local var = '' local val = ''

		for i,v in pairs( node_add ) do
			if tablex.find( leaves, i ) then
				var = var .. ',' .. i
				val = val .. ',"' .. v .. '"'
			end
		end

		sql = string.format( 'INSERT INTO leaves (node%s) VALUES ((SELECT id FROM nodes WHERE node = ?)%s)', var, val )

		db.query( sql, node_add.chld )
		----END----

		--Даем полные права создателю
		local grants = { 'access', 'delete', 'replace', 'insert', 'update', 'read', 'pass' }

		for i,v in pairs( grants ) do
			db.query( [[
				INSERT INTO acl_grants_users (user,node,grnt) VALUES (
					(SELECT id FROM users WHERE userid = ?),
					(SELECT id FROM nodes WHERE node = ?),
					(SELECT id FROM grants WHERE grnt = ?))]], node_add.id, node_add.chld, v )
		end
		----END----

		--Узнаем ид нового узла
		local new = db.query('SELECT id FROM nodes WHERE node = ?', node_add.chld )[1].id
		----END----

		return { json = { success = 'Узел ' .. node_add.chld .. ' успешно создан', id = new } }
	end	

	setmetatable( public, self )
	self.__index = self
	return public

end
