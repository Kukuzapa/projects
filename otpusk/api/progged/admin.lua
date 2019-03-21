-- Менеджер отпусков
local db = require("lapis.db")
-- Отладка
local inspect = require( 'inspect' )

local stringx = require 'pl.stringx'
local tablex = require 'pl.tablex'

local mail = require 'module.mail'

adminControllerProgged = {}
function adminControllerProgged:new( params )
	local private = {}
	local public = {}

	-- get vacation link
	-- { "userid", "vacid" }
	function adminControllerProgged:get_admin_link( params )
		local sel = db.query( [[SELECT u.name,u.id,v.begin,v.end,DATEDIFF(v.end,v.begin)+1 days,v.status,vt.type FROM vacations v 
			INNER JOIN users u ON v.user_id = u.id
			INNER JOIN vac_type vt ON v.vac_type_id = vt.id
			WHERE v.id = ?]], params.vacid )[1]

		local cross = db.query( [[SELECT v2.id,u2.name,v2.begin,v2.end,c2.competense,v2.status,DATEDIFF(v2.end,v2.begin)+1 days FROM vacations v1
			INNER JOIN vacations v2 ON v1.begin <= v2.end AND v1.end >= v2.begin
			INNER JOIN users u1 ON v1.user_id = u1.id
			INNER JOIN users u2 ON v2.user_id = u2.id
			INNER JOIN user_comp uc1 ON uc1.user_id = u1.id
			INNER JOIN user_comp uc2 ON uc2.user_id = u2.id
			INNER JOIN competenses c1 ON uc1.comp_id = c1.id
			INNER JOIN competenses c2 ON uc2.comp_id = c2.id
			WHERE v1.id = ? AND v2.id != v1.id AND v1.user_id = ? AND v2.user_id != v1.user_id AND c1.id = c2.id]], params.vacid, sel.id )

		local com = db.query( 'SELECT u.name,c.comment FROM comments c INNER JOIN users u ON c.user_id = u.id WHERE c.vacation_id = ?', params.vacid )

		local log = db.query( [[SELECT u.name,l.action,c.comment,l.date_time FROM logs l
			INNER JOIN users u ON l.user_id = u.id 
			LEFT JOIN comments c ON l.comment_id = c.id
			WHERE l.vacation_id = ? ORDER BY l.date_time DESC]], params.vacid)
		
		return { json = { sel = sel, com = com, log = log, cross = cross } }
	end
	
	-- find client
	-- { "userid", "clname" }
	function adminControllerProgged:get_admin_find( params )
		local sel = db.query( 'SELECT * FROM users WHERE name LIKE "%' .. params.clname .. '%"' )
		
		return { json = sel }
	end

	-- get users list
	-- { "userid" }
	function adminControllerProgged:get_admin_users( params )
		
		--ngx.say( params.clid )
		--local users
		
		--if params.clid ~= nil then
			--ngx.say('clid')

		--	users = db.query( [[SELECT c.competense FROM users u
		--		INNER JOIN user_comp uc ON uc.user_id = u.id
		--		INNER JOIN competenses c ON uc.comp_id = c.id
		--		WHERE u.id = ?]], params.clid )

		--	local tmp = {}

		--	for i,v in pairs( users ) do
		--		table.insert( tmp, v.competense )
		--	end

		--	users = table.concat( tmp, ', ' )
		--else	
			--users = db.query( 'SELECT * FROM users')
		--	local sql = 'SELECT * FROM users'

		--	if params.clname then
		--		sql = sql .. ' WHERE name LIKE "%' .. params.clname .. '%"'
		--	end

		--	users = db.query( sql )
		--end

		local sql = [[SELECT u.id,u.name,u.email,group_concat(c.competense SEPARATOR ', ') competense,u.isadmin FROM users u
			LEFT JOIN user_comp uc ON uc.user_id = u.id
			LEFT JOIN competenses c ON c.id = uc.comp_id]]
		
		if params.clname then
			sql = sql .. ' WHERE u.name LIKE "%' .. params.clname .. '%"'
		end

		sql = sql .. ' GROUP BY u.id'

		local users = db.query( sql )

		local sel = db.query( 'SELECT * FROM competenses' )

		local comp = {}

		for i,v in pairs( sel ) do
			table.insert( comp, v.competense )
		end
		
		return { json = { users = users, comp = comp } }
	end

	-- get log
	-- { "userid", "vacid" }
	function adminControllerProgged:get_admin_log( params )
		if params.count then

			--local count = db.query( 'SELECT count(*) FROM logs' )[1]['count(*)']
			local sql = 'SELECT count(*) count FROM logs l INNER JOIN users u ON l.user_id = u.id'

			if params.clname then
				sql = sql .. ' WHERE u.name LIKE "%' .. params.clname .. '%"'
			end

			local count = db.query( sql )[1].count

			return { json = { count = count } }
		end

		local limit = params.limit
		local offset = limit*(params.page-1)

		--local log = db.query( [[SELECT l.id,l.vacation_id,l.action,l.date_time,c.comment,u.name FROM logs l
		--	INNER JOIN users u ON l.user_id = u.id
		--	LEFT JOIN comments c ON l.comment_id = c.id ORDER BY l.date_time DESC LIMIT ? OFFSET ?]], db.raw( limit ), offset )

		local sql = [[SELECT l.id,l.vacation_id,l.action,l.date_time,c.comment,u.name FROM logs l
			INNER JOIN users u ON l.user_id = u.id
			LEFT JOIN comments c ON l.comment_id = c.id]]
		--ORDER BY l.date_time DESC LIMIT ? OFFSET ?]]
		if params.clname then
			sql = sql .. ' WHERE u.name LIKE "%' .. params.clname .. '%"'
		end

		sql = sql .. ' ORDER BY l.date_time DESC LIMIT ? OFFSET ?'

		local log = db.query( sql, db.raw( limit ), offset )
		
		return { json = log }
	end

	-- set vacation comment
	-- { "userid" }
	function adminControllerProgged:post_admin_comment( params )
		-- код писать тут
		db.query( 'INSERT INTO comments (user_id,vacation_id,comment) VALUES (?,?,?)',
			params.userid, params.param.vacid, params.param.comment )

		return {
			json = {
				success = true,
				error = false,
				message = 'NYI; DEBUG: ' .. inspect( params )
			}
		}
	end

	-- get vacation comments
	-- { "userid", "vacid" }
	function adminControllerProgged:get_admin_comment( params )
		-- код писать тут
		local sel = db.query( [[SELECT u.name, c.comment FROM comments c
							INNER JOIN users u ON c.user_id = u.id 
							WHERE c.vacation_id = ?]] , params.vacid )

		if #sel == 0 then
			return { json = { succecc = 'Никто не посчитал нужным комментировать эту заявку' } }
		end

		return { json = sel }
	end

	-- vacation cross
	-- { "userid", "vacid", "clid" }
	function adminControllerProgged:get_admin_cross( params )

		local cross = db.query( [[SELECT v2.id,u2.name,v2.begin,v2.end,c2.competense,v2.status FROM vacations v1
			INNER JOIN vacations v2 ON v1.begin <= v2.end AND v1.end >= v2.begin
			INNER JOIN users u1 ON v1.user_id = u1.id
			INNER JOIN users u2 ON v2.user_id = u2.id
			INNER JOIN user_comp uc1 ON uc1.user_id = u1.id
			INNER JOIN user_comp uc2 ON uc2.user_id = u2.id
			INNER JOIN competenses c1 ON uc1.comp_id = c1.id
			INNER JOIN competenses c2 ON uc2.comp_id = c2.id
			WHERE v1.id = ? AND v2.id != ? AND v1.user_id = ? AND v2.user_id != ? AND c1.id = c2.id]], 
			params.vacid, params.vacid, params.clid, params.clid )
		

		return { json = cross }
	end

	-- get count and vacation type
	-- { "userid", "clid" }
	function adminControllerProgged:get_admin_vacations( params )
		local date = require "date"
		
		local sel = db.query( [[SELECT * FROM vacations v 
			LEFT JOIN vac_type vt ON v.vac_type_id = vt.id
			WHERE v.status = 1 AND user_id = ?]], params.clid )

		local fin = {}

		for i,v in pairs( sel ) do

			local b = date( v.begin )

			local e = date( v['end'] )

			while b <= e do

				if not rawget( fin, tostring(b:getyear()) ) then
					fin[tostring(b:getyear())] = {}
				end

				local v_type = v.type
				if type( v.type ) == 'userdata' then
					v_type = 'Тип отпуска не определен'
				end

				if not rawget( fin[tostring(b:getyear())], v_type ) then
					fin[tostring(b:getyear())][v_type] = 0
				end
			
				fin[tostring(b:getyear())][v_type] = fin[tostring(b:getyear())][v_type] + 1

				b:adddays( 1 )
			end
		end

		if params.period ~= 'all' then
			fin = fin[params.period]
		end

		return { json = fin }
	end

	-- get current vacations list
	-- { "userid" }
	function adminControllerProgged:get_admin_list( params )

		if params.count then
			local sql = 'SELECT COUNT(v.id) count FROM vacations v INNER JOIN users u ON v.user_id = u.id WHERE v.end >= CURDATE() AND v.status IN ("1","-1")'

			if params.clname then
				sql = sql .. ' AND u.name LIKE "%' .. params.clname .. '%"'
			end

			local count = db.query( sql )[1].count

			return { json = { count = count } }
		end

		local limit = params.limit
		local offset = limit*(params.page-1)
		
		local sql = [[SELECT v.id,v.user_id,v.begin,v.end,u.name,v.status,v.vac_type_id,DATEDIFF(v.end,v.begin)+1 counts,count(c.id) comments FROM vacations v
			LEFT JOIN comments c ON c.vacation_id = v.id
			INNER JOIN users u ON v.user_id = u.id 
			WHERE v.end >= CURDATE() AND v.status IN ("1","-1")]]

		if params.clname then
			sql = sql .. ' AND u.name LIKE "%' .. params.clname .. '%"'
		end

		sql = sql .. ' GROUP BY v.id ORDER BY v.id DESC LIMIT ? OFFSET ?'

		local list = db.query( sql, db.raw( limit ), offset )
		
		return { json = list }
	end

	-- vacation decision
	-- { "command", "userid" }
	function adminControllerProgged:post_admin_vacation( params )
		local status = '-1'

		local admin = db.query( 'SELECT * FROM users WHERE id = ?', params.userid )[1].name

		local action = 'Администратор ' .. admin

		local com_id = 'NULL'

		if params.command == 'accept' then
			status = '1'
			action = action .. ' подтвердил заявку № ' .. params.param.vacid
		else
			action = action .. ' отказал заявку № ' .. params.param.vacid
		end

		action = action .. ' пользователя ' .. params.param.name

		db.query( 'UPDATE vacations SET status = ? WHERE id = ?', status, params.param.vacid )

		if params.param.comment then
			db.query( 'INSERT INTO comments (user_id,vacation_id,comment) VALUES (?,?,?)', 
				params.userid, params.param.vacid, params.param.comment )

			com_id = db.query( 'SELECT LAST_INSERT_ID()' )[1]['LAST_INSERT_ID()']
		end

		db.query( 'INSERT INTO logs (user_id,vacation_id,comment_id,action,date_time) VALUES (?,?,?,?,NOW())',
			params.userid, params.param.vacid, db.raw( com_id ), action )

		mail.admin( params.userid, params.param.vacid, status )

		return { json = { action = action } }
	end

	-- get new vacations list
	-- { "userid" }
	function adminControllerProgged:get_admin_new( params )

		--ngx.say( params.test )

		if params.count then
			local sql = 'SELECT COUNT(v.id) count FROM vacations v INNER JOIN users u ON v.user_id = u.id WHERE v.status IS NULL'

			if params.clname then
				sql = sql .. ' AND u.name LIKE "%' .. params.clname .. '%"'
			end

			local count = db.query( sql )[1].count

			return { json = { count = count } }
		end

		local limit = params.limit
		local offset = limit*(params.page-1)
		
		local sql = [[SELECT v.id,u.name,v.begin,v.end,u.id user,v.vac_type_id,DATEDIFF(v.end,v.begin)+1 counts,count(c.id) comments FROM vacations v 
			INNER JOIN users u ON v.user_id = u.id 
			LEFT JOIN comments c ON c.vacation_id = v.id
			WHERE status IS NULL]]
		
		if params.clname then
			sql = sql .. ' AND u.name LIKE "%' .. params.clname .. '%"'
		end

		sql = sql .. ' GROUP BY v.id ORDER BY v.id DESC LIMIT ? OFFSET ?'
		
		local sel = db.query( sql, db.raw( limit ), offset )

		return { json = sel }
	end

	-- get old vacations list
	-- { "userid" }
	function adminControllerProgged:get_admin_history( params )

		if params.count then
			local sql = [[SELECT COUNT(v.id) count FROM vacations v
				INNER JOIN users u ON v.user_id = u.id 
				WHERE ( (v.end < CURDATE() AND v.status IN ("1","-1") ) OR v.status = "-2" )]]

			if params.clname then
				sql = sql .. ' AND u.name LIKE "%' .. params.clname .. '%"'
			end

			local count = db.query( sql )[1].count

			return { json = { count = count } }
		end

		local limit = params.limit
		local offset = limit*(params.page-1)
		
		local sql = [[SELECT v.id,v.user_id,v.begin,v.end,u.name,v.status,v.vac_type_id,DATEDIFF(v.end,v.begin)+1 counts,count(c.id) comments FROM vacations v
			LEFT JOIN comments c ON c.vacation_id = v.id
			INNER JOIN users u ON v.user_id = u.id 
			WHERE ( (v.end < CURDATE() AND v.status IN ("1","-1") ) OR v.status = "-2" )]]

		if params.clname then
			sql = sql .. ' AND u.name LIKE "%' .. params.clname .. '%"'
		end

		sql = sql .. ' GROUP BY v.id ORDER BY v.id DESC LIMIT ? OFFSET ?'

		local history = db.query( sql, db.raw( limit ), offset )

		return { json = history }
	end

	-- set admins and competenses
	-- { "userid" }
	function adminControllerProgged:post_admin_user( params )
		
		if params.param.competenses then

			local tmp = stringx.strip( params.param.competenses )
			tmp = stringx.strip( tmp, ',' )
			tmp = stringx.split( tmp, ',' )

			for i,v in pairs( tmp ) do
				tmp[i] = stringx.strip( v )
			end

			for i,v in pairs( tmp ) do
				local sel = db.query( 'SELECT * FROM competenses WHERE competense = ?', v )
			
				if #sel == 0 then
					db.query( 'INSERT INTO competenses (competense) VALUES (?)', v )
				end
			end

			local comp = db.query( [[SELECT c.competense FROM user_comp uc
				INNER JOIN competenses c ON uc.comp_id = c.id WHERE uc.user_id = ?]], params.param.clid )

			local old = {} local add = {} local rem = {} local fin = {}

			for i,v in pairs( comp ) do
				table.insert( old, v.competense )
			end

			for i,v in pairs( old ) do
				if not tablex.find( tmp, v ) then
					table.insert( rem, v )
				end
			end

			for i,v in pairs( tmp ) do
				if not tablex.find( old, v ) then
					table.insert( add, v )
				end
				table.insert( fin, v )
			end

			for i,v in pairs( rem ) do
				db.query( 'DELETE FROM user_comp WHERE comp_id = (SELECT id FROM competenses WHERE competense = ?) AND user_id = ?',
					v, params.param.clid )

				local try = db.query( 'SELECT * FROM user_comp WHERE comp_id = (SELECT id FROM competenses WHERE competense = ?)', v )

				if #try == 0 then
					db.query( 'DELETE FROM competenses WHERE competense = ?', v )
				end
			end

			for i,v in pairs( add ) do
				db.query( 'INSERT INTO user_comp (user_id,comp_id) VALUES (?,(SELECT id FROM competenses WHERE competense = ?))',
					params.param.clid, v )
			end

			return { json = { success = table.concat( fin, ', ' ) } }
		end
		
		if params.param.isadmin then
			db.query( 'UPDATE users SET isadmin = "1" WHERE id = ?', params.param.clid )

			return { json = { success = 'ADMIN' } }
		else
			db.query( 'UPDATE users SET isadmin = NULL WHERE id = ?', params.param.clid )

			return { json = { success = 'NO ADMIN' } }
		end
		
		
	end

	setmetatable( public, self )
	self.__index = self
	return public

end
