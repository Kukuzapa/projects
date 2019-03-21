-- Менеджер паролей
local db = require("lapis.db")
local tablex = require 'pl.tablex'
local helpers = require 'module.helpers'

-- Отладка
local inspect = require( 'inspect' )

roleControllerProgged = {}
function roleControllerProgged:new( params )
	local private = {}
	local public = {}

	-- add node's grants to role
	-- {}
	--Пока не делаю. Есть ощущение, что данная операция избыточна и протеворечит концепции приложения. Со временем ощущение прошло.
	function roleControllerProgged:post_role_node( params )
		local role_node = params.param

		--Проверка авторизации пользователя
		--if not helpers.session( role_node.id, role_node.token ) then
		--	return { json = { err = 'Вы не авторизированы' } }
		--end
		----END----

		--Проверка может ли инициатор давать пользователям разрешения на узел
		for i,v in pairs( role_node.node ) do
			if not helpers.check_grant( role_node.id, i, 'access' ) then
				return { json = { err = 'Вы не можете давать права ролям на операции с узлом ' .. i } }
			end
		end
		----END----

		--Проверка существования роли
		local check_role = db.query( 'SELECT * FROM roles WHERE role = ?', role_node.role )
		if tablex.size( check_role ) == 0 then
			return { json = { err = 'Такой роли не существует' } }
		end
		local role_id = check_role[1].id
		----END----

		--Проверка существования узлов
		for i,v in pairs( role_node.node ) do
			local check_node = db.query( 'SELECT * FROM nodes WHERE node = ?', i )
			if tablex.size( check_node ) == 0 then
				return { json = { err = 'Один или несколько из указанных узлов не существуют' } }
			end
		end
		----END----

		--Начинаем работу с разрешениями к узлам. Проход по объекту узел = [ разрешения ]
		for i,v in pairs( role_node.node ) do
			--Массив разрешений пустой, т.е. убираем доступ к узлу
			if v:len() == 0 then
				helpers.remove_grants( 'roles', role_id, i )
			--Иначе, массив разрешений не пустой
			else
				helpers.set_grants( 'roles', role_id, i, v )
			end
			
		end
		----END----

		return { json = { err = 'Операция добавления/удаления прав завершена успешно' } }
	end

	-- get roles list
	-- { "id" }
	function roleControllerProgged:get_role_list( params )
		
		local fin = {}
		
		if helpers.check_admin( params.id ) then
			local sel = db.query( 'SELECT * FROM roles' )

			for i,v in pairs( sel ) do
				table.insert( fin, { text = v.role, id = v.id, data = { isadmin = true } } )
			end
		else
			local sel = db.query( [[SELECT m.id,u.user,r.role FROM managers m
				INNER JOIN users u ON m.user = u.id
				INNER JOIN roles r ON m.role = r.id
				WHERE u.userid = ?]], params.id )
			for i,v in pairs( sel ) do
				table.insert( fin, { text = v.role, id = v.id, data = { isadmin = false } } )
			end
		end

		--local fin = db.query( 'SELECT * FROM roles' )

		return { json = fin }

	end

	-- get role info
	-- { "id", "role" }
	function roleControllerProgged:get_role_get( params )
		--Проверка прав на операцию
		local role_get = params

		--Проверка авторизации пользователя
		--if not helpers.session( role_get.id, role_get.token ) then
		--	return { json = { err = 'Вы не авторизированы' } }
		--end
		----END----

		local fin = {}

		fin.manager = {}
		fin.users = {}
		fin.node = {}
		
		if not helpers.check_manager( role_get.id, role_get.role ) then
			return { json = { err = 'У вас нет прав на просмотр роли' } }
		end
		----END----

		--Проверка существования роли
		local check_role = db.query( 'SELECT * FROM roles WHERE role = ?', role_get.role )
		if tablex.size( check_role ) == 0 then
			return { json = { err = 'Такой роли не существует' } }
		end
		----END----

		local manager = db.query([[SELECT users.user FROM managers
									INNER JOIN users ON managers.user = users.id
    								INNER JOIN roles ON managers.role = roles.id
    								WHERE roles.role = ?]], role_get.role )
		--ngx.say(inspect(manager))

		for i,v in pairs( manager ) do
			--ngx.say(v.user)
			fin.manager[i] = v.user
		end

		local users = db.query([[SELECT users.user FROM roles_users
									INNER JOIN users ON roles_users.user = users.id
    								INNER JOIN roles ON roles_users.role = roles.id
    								WHERE roles.role = ?]], role_get.role )

		for i,v in pairs( users ) do
			--ngx.say(v.user)
			fin.users[i] = v.user
		end

		local node = db.query([[SELECT nodes.node,grants.grnt FROM acl_grants_roles 
									INNER JOIN roles ON acl_grants_roles.role = roles.id
								    INNER JOIN nodes ON acl_grants_roles.node = nodes.id
								    INNER JOIN grants ON acl_grants_roles.grnt = grants.id
								    WHERE roles.role = ?]], role_get.role )
		--ngx.say(inspect(node))

		for i,v in pairs( node ) do
			if not rawget( fin.node, v.node ) then
				fin.node[v.node] = {}
			end
			table.insert( fin.node[v.node], v.grnt )
		end		



		return {
			json = fin
		}
	end

	-- add user into role
	-- {}
	function roleControllerProgged:post_role_useradd( params )
		-- код писать тут
		local role_useradd = params.param

		--Проверка авторизации пользователя
		--if not helpers.session( role_useradd.id, role_useradd.token ) then
		--	return { json = { err = 'Вы не авторизированы' } }
		--end
		----END----

		--Проверка прав на операцию
		if not helpers.check_manager( role_useradd.id, role_useradd.role ) then
			return { json = { err = 'У вас нет прав на добавление/удаление пользователей в данную роль' } }
		end
		----END----

		--Проверка существования роли
		local check_role = db.query( 'SELECT * FROM roles WHERE role = ?', role_useradd.role )
		if tablex.size( check_role ) == 0 then
			return { json = { err = 'Такой роли не существует' } }
		end
		----END----

		--Добавляем пользователей в роль
		for i,v in pairs( role_useradd.user ) do
			--Проверка существовании записи
			local check = db.query( [[
				SELECT users.user,roles.role FROM roles_users
					INNER JOIN users ON roles_users.user = users.id
				    INNER JOIN roles ON roles_users.role = roles.id
					WHERE users.user = ? AND roles.role = ?]], v, role_useradd.role )
			--Если нет, добавляем
			if tablex.size( check ) == 0 then
				db.query( [[
					INSERT INTO roles_users (user,role) VALUES(
						(SELECT id FROM users WHERE user = ?),
						(SELECT id FROM roles WHERE role = ?))]], v, role_useradd.role )
			end
		end
		----END----

		return { json = { success = 'Добавление пользователей в роль ' .. role_useradd.role .. ' прошло успешно' } }
	end

	-- add role
	-- {}
	function roleControllerProgged:post_role_add( params )
		-- код писать тут
		local role_add = params.param

		--Проверка авторизации пользователя
		--if not helpers.session( role_add.id, role_add.token ) then
		--	return { json = { err = 'Вы не авторизированы' } }
		--end
		----END----

		--Проверка прав на данную операцию
		--local check_admin = db.query([[
		--	SELECT roles.role,roles_users.exp_date FROM roles_users
		--		INNER JOIN users ON roles_users.user = users.id
    	--		INNER JOIN roles ON roles_users.role = roles.id
    	--		WHERE users.id = ? AND roles.role = 'admins']], role_add.id )

		--if tablex.size( check_admin ) == 0 then
		--	return { json = { err = 'Вы не можете давать/запрещать пользователям доступ к узлам' } }
		--end
		if not helpers.check_admin( role_add.id ) then
			return { json = { err = 'Вы не можете выполнять операции по добавлению ролей' } }
		end
		----END----

		--Проверка уникальности имени роли
		local check_role = db.query( 'SELECT * FROM roles WHERE role = ?', role_add.role )
		if tablex.size( check_role ) > 0 then
			return { json = { err = 'Роль с таким именем уже существует' } }
		end
		----END----

		--Проверим существование менеджера, если он указан
		--if role_add.manager then
		--	local check_manager = db.query( 'SELECT * FROM users WHERE user = ?', role_add.manager )
		--	if tablex.size( check_manager ) == 0 then
		--		return { json = { err = 'Пользователь, указанный в качестве менеджера, не заведен' } }
		--	end
		--end
		----END----

		--Создаем роль
		db.query( 'INSERT INTO roles (role) VALUES (?)', role_add.role )

		local role_id = db.query( 'SELECT id FROM roles WHERE role = ?', role_add.role )[1].id
		----END----

		--Если был указан менеджер, прописываем его как менеджера и как члена группы
		if role_add.manager then
			db.query( [[INSERT INTO managers (user,role) VALUES (
							(SELECT id FROM users WHERE user = ?),
							(SELECT id FROM roles WHERE role = ?))]], role_add.manager, role_add.role )
			db.query( [[INSERT INTO roles_users (user,role) VALUES (
							(SELECT id FROM users WHERE user = ?),
							(SELECT id FROM roles WHERE role = ?))]], role_add.manager, role_add.role )
		end
		----END----

		--Даем право на чтение нулевого узла
		local node = db.query( 'SELECT node FROM nodes WHERE pid IS NULL')[1].node

		helpers.set_grants( 'roles', role_id, node, 'pass' )
		----END----

		return { json = { success = 'Роль ' .. role_add.role .. ' успешно добавлена', id = role_id } }
	end

	-- remove role
	-- {}
	function roleControllerProgged:post_role_remove( params )
		-- код писать тут
		local role_remove = params.param

		--Проверка авторизации пользователя
		--if not helpers.session( role_remove.id, role_remove.token ) then
		--	return { json = { err = 'Вы не авторизированы' } }
		--end
		----END----

		if not helpers.check_admin( role_remove.id ) then
			return { json = { err = 'Вы не можете выполнять операции по удалению ролей' } }
		end

		db.query( 'DELETE FROM roles WHERE role = ?', role_remove.role )

		return { json = { success = 'Роль ' .. role_remove.role .. ' успешно удалена' } }
	end

	-- remove user from role
	-- {}
	function roleControllerProgged:post_role_userrem( params )
		-- код писать тут
		local role_userrem = params.param

		--Проверка авторизации пользователя
		--if not helpers.session( role_userrem.id, role_userrem.token ) then
		--	return { json = { err = 'Вы не авторизированы' } }
		--end
		----END----

		--Проверка прав на операцию
		if not helpers.check_manager( role_userrem.id, role_userrem.role ) then
			return { json = { err = 'У вас нет прав на добавление/удаление пользователей в данную роль' } }
		end
		----END----

		--Проверка существования роли
		local check_role = db.query( 'SELECT * FROM roles WHERE role = ?', role_userrem.role )
		if tablex.size( check_role ) == 0 then
			return { json = { err = 'Такой роли не существует' } }
		end
		----END----

		--Удаляем пользователей из роли
		for i,v in pairs( role_userrem.user ) do
			db.query( [[
				DELETE FROM roles_users WHERE
					user = (SELECT id FROM users WHERE user = ?) AND
					role = (SELECT id FROM roles WHERE role = ?)]], v, role_userrem.role )
			--Если пользователь менеджер роли, то удаляем запись об этом
			db.query( [[
				DELETE FROM managers WHERE
					user = (SELECT id FROM users WHERE user = ?) AND
					role = (SELECT id FROM roles WHERE role = ?)]], v, role_userrem.role )
		end
		----END----

		return { json = { success = 'Удаление пользователей из роли ' .. role_userrem.role .. ' прошло успешно' } }
	end

	-- add/rem manger to role
	-- {}
	function roleControllerProgged:post_role_manager( params )
		-- код писать тут
		local role_manager = params.param

		--Проверка авторизации пользователя
		--if not helpers.session( role_manager.id, role_manager.token ) then
		--	return { json = { err = 'Вы не авторизированы' } }
		--end
		----END----

		--[[for i,v in pairs( role_manager.manager ) do
			if v == 'super user' then
				return { json = { err = 'Руки прочь!' } }
			end
		end]]

		--Проверка прав на операцию
		if not helpers.check_manager( role_manager.id, role_manager.role ) then
			return { json = { err = 'У вас нет прав на управление ролью' } }
		end
		----END----

		--Проверяем является ли перспективный менеджер членом роли
		for i,v in pairs( role_manager.manager ) do

			local check = db.query( 'SELECT * FROM roles_users WHERE user = (SELECT id FROM users WHERE user = ?) AND role = (SELECT id FROM roles WHERE role = ?)', v, role_manager.role )

			if tablex.size(check) == 0 then
				db.query('INSERT INTO roles_users (role,user) VALUES ((SELECT id FROM roles WHERE role = ?),(SELECT id FROM users WHERE user = ?))', role_manager.role, v )
			end
		end
		----END----

		--Воззьмем список текущих менеджеров и создадим список новых
		local current_manager = db.query( [[
			SELECT * FROM managers 
				INNER JOIN roles ON managers.role = roles.id 
				INNER JOIN users ON managers.user = users.id 
				WHERE roles.role = ?]], role_manager.role )

		for i,v in pairs( current_manager ) do
			current_manager[i] = v.user
		end

		local manager_add, manager_rem = helpers.add_rem( role_manager.manager, current_manager )
		----END----

		--Мы не можем удалить супер из роли админов
		if tablex.find( manager_rem, 'super user' ) and role_manager.role == 'admins' then
			--ngx.say( tablex.find( manager_rem, 'super user' ) )
			table.remove( manager_rem, tablex.find( manager_rem, 'super user' ) )
		end
		----END----

		--Добавляем/удаляем менеджеров
		for i,v in pairs( manager_add ) do
			db.query( [[
				INSERT INTO managers (user,role) VALUES (
					(SELECT id FROM users WHERE user = ?),
					(SELECT id FROM roles WHERE role = ?))]], v, role_manager.role )
		end

		for i,v in pairs( manager_rem ) do
			db.query( [[
				DELETE FROM managers WHERE
					user = (SELECT id FROM users WHERE user = ?) AND
					role = (SELECT id FROM roles WHERE role = ?)]], v, role_manager.role )
		end
		----END----

		return { json = { success = 'УРА!!!' } }
	end

	setmetatable( public, self )
	self.__index = self
	return public

end
