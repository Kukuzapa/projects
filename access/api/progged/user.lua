-- Менеджер паролей
local db = require("lapis.db")
local tablex = require 'pl.tablex'
local helpers = require 'module.helpers'


-- Отладка
local inspect = require( 'inspect' )

userControllerProgged = {}
function userControllerProgged:new( params )
	local private = {}
	local public = {}

	-- add user
	-- {}
	function userControllerProgged:post_user_add( params )
		-- код писать тут
		--local fin

		local user_add = params.param

		--Проверка авторизации пользователя
		if not helpers.session( user_add.id, user_add.token ) then
			return { json = { err = 'Вы не авторизированы' } }
		end
		----END----

		--Получаем список ролей инициатора операции
		if not helpers.check_admin( user_add.id ) then
			return { json = { err = 'Вы не можете выполнять операции по заведению новых пользователей' } }
		end
		----END----

		--Проверим на дубль имени
		local check_user = db.query( 'SELECT * FROM users WHERE user = ?', user_add.name )
		if tablex.size( check_user ) > 0 then
			return { json = { err = 'Пользователь с таким именем уже существует' } }
		end
		----END----

		--Если указана роль, проверяем ее наличие
		if user_add.role then
			local check_role = db.query( 'SELECT * FROM roles WHERE role = ?', user_add.role )
			if tablex.size( check_role ) == 0 then
				return { json = { err = 'Такой группы не существует' } }
			end
		end

		--Создаем пользователя, получаем его ид
		db.query( 'INSERT INTO users (user) VALUES (?)', user_add.name )

		local user_id = db.query( 'SELECT id FROM users WHERE user = ?', user_add.name )[1].id
		----END----

		--Даем новому пользователю права на проход корневого узла
		local node = db.query( 'SELECT node FROM nodes WHERE pid IS NULL')[1].node

		helpers.set_grants( 'users', user_id, node, 'pass' )
		----END----

		--Если указана роль добавляем в нее юзера
		if user_add.role then
			db.query([[
				INSERT INTO roles_users (user,role) VALUES (
					(SELECT id FROM users WHERE user = ?),
					(SELECT id FROM roles WHERE role = ?))]], user_add.name, user_add.role )
		end
		----END----

		return { json = { success = 'Пользователь ' .. user_add.name .. ' успешно добавлен' } }
	end

	-- get user info
	-- { "id", "user" }
	function userControllerProgged:get_user_get( params )
		local user_get = params

		--print( 'HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH' )
		--print( inspect( user_get ) )

		if user_get.name and user_get.email then
			--Проверка совпадения кеша с данными КИКа
			local sel = db.query( 'SELECT * FROM users WHERE userid = ?', user_get.user )
			--print( inspect( sel ) )

			if user_get.name ~= sel[1].user or user_get.email ~= sel[1].email then
				db.query( 'UPDATE users SET user = ?, email = ? WHERE userid = ?', user_get.name, user_get.email, user_get.user )			
			end
			----END----
		end

		--Проверка авторизации пользователя
		--if not helpers.session( user_get.id, user_get.token ) then
		--	return { json = { err = 'Вы не авторизированы' } }
		--end
		----END----

		local fin  = {}
		fin.roles  = {}
		fin.grants = {}
		fin.manager = {}

		--Получаем список ролей пользователя
		local user_roles = db.query([[
			SELECT roles.role,managers.id FROM roles_users
				INNER JOIN users ON roles_users.user = users.id
			    INNER JOIN roles ON roles_users.role = roles.id
			    LEFT JOIN managers ON managers.user = users.id AND managers.role = roles.id
				WHERE users.userid = ?]], user_get.user )

		for i,v in pairs( user_roles ) do
			--local str = ''
			--str = str .. v.role
			if type( v.id ) ~= 'userdata' then
				table.insert( fin.manager, v.role )
			end
			fin.roles[i] = v.role
		end
		----END----

		--Список ролей, в которых пользователь администратор
		--local managers = db.query(  )
		----END----

		--Список разрешений на узлы
		local user_grants = db.query([[
			SELECT nodes.node,grants.grnt FROM acl_grants_users 
				INNER JOIN users ON acl_grants_users.user = users.id
			    INNER JOIN nodes ON acl_grants_users.node = nodes.id
			    INNER JOIN grants ON acl_grants_users.grnt = grants.id
			    WHERE users.userid = ?]], user_get.user )

		for i,v in pairs( user_grants ) do
			if not rawget( fin.grants, v.node ) then
				fin.grants[v.node] = {}
			end
			table.insert( fin.grants[v.node], v.grnt )
		end
		----END----

		--Нам не нужны пустые поля
		for i,v in pairs( fin ) do
			if tablex.size( v ) == 0 then
				fin[i] = nil
			end
		end

		return { json = fin }
	end

	-- user's roles
	-- {}
	function userControllerProgged:post_user_role( params )
		local user_role = params.param

		--Проверка авторизации пользователя
		--if not helpers.session( user_role.id, user_role.token ) then
		--	return { json = { err = 'Вы не авторизированы' } }
		--end
		----END----

		local check_user = db.query( 'SELECT * FROM users WHERE user = ?', user_role.name )
		if tablex.size( check_user ) == 0 then
			return { json = { err = 'Пользователя с таким именем не существует' } }
		end

		--Если массив ролей пуст, то просто удаляем пользователя из всех ролей
		if #user_role.role == 0 then
			db.query( 'DELETE FROM trees.roles_users WHERE user = (SELECT id FROM users WHERE user = ?)', user_role.name )
			return { json = { success = 'Операция добавления/удаления ролей завершена успешно' } }
		end
		----END----

		--Проверим существуют ли роли
		local tmp = {}

		for i,v in pairs( user_role.role ) do
			table.insert( tmp, '"' .. v .. '"' )
		end

		local sql = 'SELECT * FROM roles WHERE role IN (%s)'

		local check_role = db.query( string.format( sql,table.concat(tmp,',') ) )

		if #check_role ~= #user_role.role then
			return { json = { err = 'Одна или несколько из указанных ролей не существует' } }
		end
		----END----

		--Проверка прав на выполнение данной операции. Ее могут выполнять менеджеры ролей или админы
		for i,v in pairs( user_role.role ) do
			if not helpers.check_manager( user_role.id, v ) then
				return { json = { err = 'Вы не можете выполнять операции по добавлению пользователей в группы' } }
			end
		end
		----END----
		
		--Обновляем список ролей.
		local current_role = db.query([[
			SELECT roles.role FROM roles_users
				INNER JOIN users ON roles_users.user = users.id
				INNER JOIN roles ON roles_users.role = roles.id
				WHERE users.user = ?]], user_role.name )

		for i,v in pairs( current_role ) do
			current_role[i] = v.role
		end

		local role_add, role_rem = helpers.add_rem( user_role.role, current_role )

		for i,v in pairs( role_rem ) do
			db.query( 'DELETE FROM roles_users WHERE role = (SELECT id FROM roles WHERE role = ?)', v )
		end

		for i,v in pairs( role_add ) do
			db.query( [[
				INSERT INTO roles_users (user,role) VALUES (
					(SELECT id FROM users WHERE user = ?),
					(SELECT id FROM roles WHERE role = ?))]], user_role.name, v )
		end
		----END----

		return { json = { success = 'Операция добавления/удаления ролей завершена успешно' } }
	end

	-- remove user
	-- {}
	function userControllerProgged:post_user_remove( params )
		-- код писать тут
		local user_rem = params.param

		--Проверка авторизации пользователя
		if not helpers.session( user_rem.id, user_rem.token ) then
			return { json = { err = 'Вы не авторизированы' } }
		end
		----END----

		for i,v in pairs( user_rem.name ) do
			if v == 'super user' then
				return { json = { err = 'Руки прочь!' } }
			end
		end

		if not helpers.check_admin( user_rem.id ) then
			return { json = { err = 'Вы не можете выполнять операции по удалению пользователей' } }
		end

		local tmp = {}

		for i,v in pairs( user_rem.name ) do
			table.insert( tmp, '"' .. v .. '"' )
		end

		local sql = 'DELETE FROM users WHERE user IN (%s)'

		db.query( string.format( sql,table.concat(tmp,',') ) )

		if tablex.size( user_rem.name ) == 1 then
			return { json = { success = 'Пользователь ' .. user_rem.name[1] .. ' успешно удален' } }
		else
			local str = 'Пользователи %s успешно удалены'
			return { json = { success = string.format( str,table.concat(user_rem.name,',') ) } }
		end
	end

	-- user's node grants
	-- {}
	function userControllerProgged:post_user_node( params )
		local user_node = params.param

		--Проверка авторизации пользователя
		--if not helpers.session( user_node.id, user_node.token ) then
		--	return { json = { err = 'Вы не авторизированы' } }
		--end
		----END----

		if user_node.name == 'super user' then
			return { json = { err = 'Руки прочь!' } }
		end

		--Проверка может ли инициатор давать пользователям разрешения на узел
		for i,v in pairs( user_node.node ) do
			if not helpers.check_grant( user_node.id, i, 'access' ) then
				return { json = { err = 'Вы не можете давать права пользователям на операции с узлом ' .. i } }
			end
		end
		----END----

		--Проверка существования пользователя, получение его ид
		local check_user = db.query( 'SELECT * FROM users WHERE user = ?', user_node.name )
		
		if tablex.size( check_user ) == 0 then
			return { json = { err = 'Пользователя с таким именем не существует' } }
		end

		local user_id = check_user[1].id
		----END----

		--Проверка существования узлов
		for i,v in pairs( user_node.node ) do
			local check_node = db.query( 'SELECT * FROM nodes WHERE node = ?', i )
			if tablex.size( check_node ) == 0 then
				return { json = { err = 'Один или несколько из указанных узлов не существуют' } }
			end
		end
		----END----

		--Начинаем работу с разрешениями к узлам. Проход по объекту узел = [ разрешения ]
		for i,v in pairs( user_node.node ) do
			
			--local parents = helpers.get_parents( i )

			--ngx.say(inspect(parents))

			--Массив разрешений пустой, т.е. убираем доступ к узлу
			if v:len() == 0 then
				helpers.remove_grants( 'users', user_id, i )
			--Иначе, массив разрешений не пустой
			else
				helpers.set_grants( 'users', user_id, i, v )
			end
		end
		----END----

		return { json = { success = 'Операция добавления/удаления прав завершена успешно' } }
	end

	setmetatable( public, self )
	self.__index = self
	return public

end
