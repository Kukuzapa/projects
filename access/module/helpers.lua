local helpers = {}

local db     = require 'lapis.db'
local tablex = require 'pl.tablex'
local stringx = require 'pl.stringx'
local inspect = require( 'inspect' )

--Таблица разрешений
local AM_GRANTS = {
	access  = { 'access' , 'delete' , 'replace', 'insert', 'update', 'read', 'pass' },
	delete  = { 'delete' , 'replace', 'insert' , 'update', 'read'  , 'pass' },
	replace = { 'replace', 'insert' , 'update' , 'read'  , 'pass' },
	insert  = { 'insert' , 'update' , 'read'   , 'pass' },
	update  = { 'update' , 'read'   , 'pass' },
	read    = { 'read'   , 'pass' },
	pass    = { 'pass' },
}
----END----

--Шаблоны таблиц пользователи/роли
local TEMPL = {
	users = { tbl = 'users', col = 'user', grnt = 'acl_grants_users' },
	roles = { tbl = 'roles', col = 'role', grnt = 'acl_grants_roles' }
}
----END----

--Проверяем является ли пользователь админом
function helpers.check_admin( id )
	
	--local check = db.query([[
	--	SELECT roles.role,roles_users.exp_date FROM roles_users
	--		INNER JOIN users ON roles_users.user = users.id
	--		INNER JOIN roles ON roles_users.role = roles.id
	--		WHERE users.id = ? AND roles.role = 'admins']], id )

	local check = db.query( [[SELECT * FROM users u
		INNER JOIN roles_users ru ON u.id = ru.user
		INNER JOIN roles r ON r.id = ru.role
		WHERE u.userid = ? AND r.role = 'admins']], id )

	if tablex.size( check ) == 0 then
		return false
	else 
		return true
	end
end
----END----

--Проверка является ли инициатор менеджером группы или админом
function helpers.check_manager( id, role )
	local check = db.query([[
		SELECT users.id,users.user,roles.role FROM roles_users
			INNER JOIN users ON roles_users.user = users.id
			INNER JOIN roles ON roles_users.role = roles.id
			WHERE users.userid = ? AND roles.role = 'admins'
		UNION ALL
		SELECT managers.id,users.user,roles.role FROM managers
			INNER JOIN users ON managers.user = users.id
		    INNER JOIN roles ON managers.role = roles.id
		    WHERE users.userid = ? AND roles.role = ?]], id, id, role )
	if tablex.size( check ) == 0 then
		return false
	else 
		return true
	end
end
----END----

--Проверяем права пользователя на выполнение операции над узлом
function helpers.check_grant( id, node, grnt )

	--[[ngx.say(id)
	ngx.say(node)
	ngx.say(grnt)]]
	
	local check = db.query([[
		SELECT users.id FROM roles_users
			INNER JOIN users ON roles_users.user = users.id
			INNER JOIN roles ON roles_users.role = roles.id
			WHERE users.userid = ? AND roles.role = 'admins'
		UNION ALL
		SELECT users.id FROM nodes
			INNER JOIN acl_grants_users ON acl_grants_users.node = nodes.id
			INNER JOIN users ON acl_grants_users.user = users.id
			INNER JOIN grants ON acl_grants_users.grnt = grants.id
			WHERE grants.grnt = ? AND users.userid = ? AND nodes.node = ?
		UNION ALL
		SELECT users.id FROM nodes
			INNER JOIN acl_grants_roles ON acl_grants_roles.node = nodes.id
			INNER JOIN grants ON acl_grants_roles.grnt = grants.id 
			INNER JOIN roles ON acl_grants_roles.role = roles.id 
			INNER JOIN roles_users ON roles_users.role = roles.id
			INNER JOIN users ON roles_users.user = users.id
			WHERE grants.grnt = ? AND users.userid = ? AND nodes.node = ?]], id, grnt, id, node, grnt, id, node )

	--ngx.say(inspect(check))

	if tablex.size( check ) == 0 then
		return false
	else 
		return true
	end
end
----END----

--Обработка списков удаления и добавления
function helpers.add_rem( new, old )
	
	local rem = {} local add = {}

	for i,v in pairs( new ) do
		if not tablex.find( old, v ) then
			table.insert( add, v )
		end
	end

	for i,v in pairs( old ) do
		if not tablex.find( new, v ) then
			table.insert( rem, v )
		end
	end

	--ngx.say(add)

	return add,rem
end
----END----

--Получение списка детей родителя, включая родителя
function helpers.get_childrens( node, column )
	local childrens = db.query( [[
						WITH RECURSIVE get_tree AS
							(SELECT id,node,pid FROM nodes WHERE node = ?
							UNION ALL
							SELECT n.id, n.node, n.pid FROM nodes n INNER JOIN get_tree g ON n.pid = g.id)
							SELECT * FROM get_tree]], node )
	
	if column then
		for i,v in pairs( childrens ) do
			childrens[i] = v[column]
		end
	end

	return childrens	
end
----END----

--Получение списка родителей узла, не включая сам узел
function helpers.get_parents( node, column )
	local parents = db.query( [[
						WITH RECURSIVE get_tree AS
							(SELECT id,node,pid FROM nodes WHERE id = (SELECT pid FROM nodes WHERE node = ?)
							UNION ALL
							SELECT n.id, n.node, n.pid FROM nodes n INNER JOIN get_tree g ON n.id = g.pid)
							SELECT * FROM get_tree]], node )
	
	if column then
		for i,v in pairs( parents ) do
			parents[i] = v[column]
		end
	end

	return parents	
end
----END----

--Полное удаление прав на узел у пользователя/роли, включая детей.
--Проход по родителям. Удаление ненужных прав.
function helpers.remove_grants( typ, id, node )

	--Готовим список дочерних узлов для вставки в sql и сносим права
	local tmp = helpers.get_childrens( node, 'id' )

	for i,v in pairs( tmp ) do
		tmp[i] = '"' .. v .. '"'
	end

	tmp = table.concat( tmp, ',' )

	local sql = 'DELETE FROM %s WHERE node IN (%s) AND %s = %s'

	db.query( string.format( sql, TEMPL[typ].grnt, tmp, TEMPL[typ].col, id ) )
	----END----

	--Обрабатываем вышестоящее дерево
	local tmp = helpers.get_parents( node )

	--for i,v in pairs( tmp ) do
	--	tmp[i] = '"' .. v .. '"'
	--end

	--tmp = table.concat( tmp, ',' )

	for i,v in pairs( tmp ) do
		if type( v.pid ) ~= 'userdata' then
			local sql1 = 'SELECT * FROM %s WHERE %s = %s AND node IN (SELECT id FROM nodes WHERE pid = %s)'
			local sql2 = 'SELECT * FROM %s WHERE %s = %s AND node = %s'

			local pass = db.query( 'SELECT * FROM grants WHERE grnt = "pass"' )[1].id

			local check1 = db.query( string.format( sql1, TEMPL[typ].grnt, TEMPL[typ].col, id, v.id ) )
			
			local check2 = db.query( string.format( sql2, TEMPL[typ].grnt, TEMPL[typ].col, id, v.id ) )
			
			if #check1 == 0 and #check2 == 1 and check2[1].grnt == pass then
				local del = 'DELETE FROM %s WHERE node = %s AND %s = %s'
				db.query( string.format( del, TEMPL[typ].grnt, v.id, TEMPL[typ].col, id ) )
			else
				break
			end
		end
	end

	--ngx.say(tmp)
	----END----

end
----END----

--Получения списка прав пользователя/роли у узла
function helpers.get_grants( typ, id, node, column )
	
	local sql = [[SELECT grants.grnt FROM %s 
					INNER JOIN %s ON %s.%s = %s.id
					INNER JOIN nodes ON %s.node = nodes.id
					INNER JOIN grants ON %s.grnt = grants.id
					WHERE %s.id = ? AND nodes.node = ?]]

	local tmpl = TEMPL[typ]

	--ngx.say( string.format( sql, tmpl.grnt, tmpl.tbl, tmpl.grnt, tmpl.col, tmpl.tbl, tmpl.grnt, tmpl.grnt, tmpl.tbl ))

	local grants = db.query( string.format( sql, tmpl.grnt, tmpl.tbl, tmpl.grnt, tmpl.col, tmpl.tbl, tmpl.grnt, tmpl.grnt, tmpl.tbl ), id, node )

	if column then
		for i,v in pairs( grants ) do
			grants[i] = v[column]
		end
	end

	return grants
end
----END----

--Вадача прав пользователю/группе на узел
function helpers.set_grants( typ, id, node, grnt )
	
	local node_id = db.query( 'SELECT id FROM nodes WHERE node = ?', node )[1].id

	local ins = 'INSERT INTO %s (%s,node,grnt) VALUES (%s,?,(SELECT id FROM grants WHERE grnt = ?))'

	ins = string.format( ins, TEMPL[typ].grnt, TEMPL[typ].col, id )
	
	local del = 'DELETE FROM %s WHERE node = %s AND %s = %s AND grnt = (SELECT id FROM grants WHERE grnt = ?)'

	del = string.format( del, TEMPL[typ].grnt, node_id, TEMPL[typ].col, id )

	--[[ngx.say(type(grnt))
	ngx.say(AM_GRANTS[grnt])
	ngx.say(AM_GRANTS['pass'])

	if grnt == 'pass' then
		ngx.say('bingo')
	end]]

	local add,rem = helpers.add_rem( AM_GRANTS[grnt], helpers.get_grants( typ, id, node, 'grnt' ) )

	for i,v in pairs( add ) do
		db.query( ins, node_id, v )	
	end

	for i,v in pairs( rem ) do
		db.query( del, v )	
	end

	--Даем право на проход вышестоящим, если еще нет
	local parents = helpers.get_parents( node, 'node' )

	for i,v in pairs( parents ) do
		local check = helpers.get_grants( typ, id, v )
		if #check == 0 then
			local node_id = db.query( 'SELECT id FROM nodes WHERE node = ?', v )[1].id
			db.query( ins, node_id, 'pass' )
		end
	end
end
----END----

--Получаем timestamp from datetime
function helpers.get_timestamp( str )
	
	local split = stringx.split( str )
	local date = stringx.split( split[1], '-' )
	local time = stringx.split( split[2], ':' )

	local dt = { year=date[1], month=date[2], day=date[3], hour=time[1], min=time[2], sec=time[3] }

	local tmstmp = os.time(dt)

	return tmstmp
end
----END----

--Проверка рабочей сессии пользователя
function helpers.session( user, token )

	if not token then
		return false
	end

	local session = db.query( 'SELECT * FROM session WHERE client = ? AND access = ?', user, token )

	if #session > 0 then
		return true
	else
		return false
	end
end
----END----

return helpers