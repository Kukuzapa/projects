-- Менеджер отпусков
local db = require("lapis.db")

-- Отладка
local inspect = require( 'inspect' )

baseControllerProgged = {}
function baseControllerProgged:new( params )
	local private = {}
	local public = {}

	-- set vacation comment
	-- { "userid" }
	function baseControllerProgged:post_comment( params )
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
	function baseControllerProgged:get_comment( params )
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
	function baseControllerProgged:get_cross( params )

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

	-- find client
	-- { "userid", "clname" }
	function baseControllerProgged:get_find( params )
		local sel = db.query( 'SELECT * FROM users WHERE name LIKE "%' .. params.clname .. '%"' )
		
		return { json = sel }
	end

	-- get log
	-- { "userid", "vacid" }
	function baseControllerProgged:get_log( params )
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

	-- get users list
	-- { "userid" }
	function baseControllerProgged:get_users( params )
		
		--ngx.say( params.clid )
		local users
		
		if params.clid ~= nil then
			--ngx.say('clid')

			users = db.query( [[SELECT c.competense FROM users u
				INNER JOIN user_comp uc ON uc.user_id = u.id
				INNER JOIN competenses c ON uc.comp_id = c.id
				WHERE u.id = ?]], params.clid )

			local tmp = {}

			for i,v in pairs( users ) do
				table.insert( tmp, v.competense )
			end

			users = table.concat( tmp, ', ' )
		else	
			--users = db.query( 'SELECT * FROM users')
			local sql = 'SELECT * FROM users'

			if params.clname then
				sql = sql .. ' WHERE name LIKE "%' .. params.clname .. '%"'
			end

			users = db.query( sql )
		end
		
		return { json = users }
	end

	-- get count and vacation type
	-- { "userid", "clid" }
	function baseControllerProgged:get_vacations( params )
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

	setmetatable( public, self )
	self.__index = self
	return public

end
