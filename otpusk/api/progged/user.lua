-- Менеджер отпусков
--local helpers = require 'module.helpers'
local db = require("lapis.db")
local stringx = require 'pl.stringx'
local http = require("lapis.nginx.http")
local util = require("lapis.util")

local mail = require 'module.mail'

-- Отладка
local inspect = require( 'inspect' )

userControllerProgged = {}
function userControllerProgged:new( params )
	local private = {}
	local public = {}

	-- create vacation
	-- { "userid" }
	function userControllerProgged:post_user_vacation( params )
		
		local fin = {}

		local vac_id
		local com_id = 'NULL'
		local action

		local vac_type
		if params.param.type == 'org' then
			vac_type = 1
		else
			vac_type = 2
		end

		local user_create = params.param

		--Получим пересеения
		local check_cross = db.query([[
			SELECT v.id, v.begin, v.end, u.name, c.competense, v.status FROM vacations v 
				INNER JOIN users u ON u.id = v.user_id
    			INNER JOIN user_comp uc ON uc.user_id = v.user_id
    			INNER JOIN competenses c ON c.id = uc.comp_id
    		WHERE u.id != ? AND c.id IN (
				SELECT comp_id FROM user_comp 
					INNER JOIN users ON users.id = user_comp.user_id 
				WHERE users.id = ?)
    		AND ? <= v.end AND ? >= v.begin
		]], params.userid, params.userid, user_create.begin_date, user_create.end_date )
		
		--Если это команда отправки, то отправляем
		if params.command == 'send' then
			local check_repeat = db.query( 'SELECT * FROM vacations WHERE user_id = ? AND begin = ? AND end = ?',
				params.userid, user_create.begin_date, user_create.end_date )

			if #check_repeat > 0 then
				if check_repeat[1].status == -2 or check_repeat[1].status == -1 then
					db.query( 'UPDATE vacations SET status = NULL WHERE id = ? AND user_id = ?', 
						check_repeat[1].id, check_repeat[1].user_id )

					vac_id = check_repeat[1].id
					
					if user_create.comment then
						db.query( 'INSERT INTO comments (user_id,vacation_id,comment) VALUES (?,?,?)',
							check_repeat[1].user_id, check_repeat[1].id, user_create.comment )

						com_id = db.query( 'SELECT LAST_INSERT_ID()' )[1]['LAST_INSERT_ID()']
					end

					action = 'Заявка № ' .. vac_id .. ' повторно отправлена на рассмотрение'

					--ngx.say(vac_id, com_id, action)

					db.query( 'INSERT INTO logs (user_id,vacation_id,comment_id,action,date_time) VALUES (?,?,?,?,NOW())',
						params.userid, vac_id, db.raw( com_id ), action )

					--TODO добавить уведомление при повторной завке
					--mail.send( params.userid, user_create.begin_date, user_create.end_date, vac_type, vac_id, check_cross, user_create.comment )

					return { json = { succecc = 'Заявка отправлена на рассмотрение администратору' } }
				else
					return { json = { err = 'Уже существует заявка с указанными датами' } }
				end
			end


			db.query('INSERT INTO vacations (user_id,begin,end,vac_type_id) VALUES (?,?,?,?)', 
				params.userid, user_create.begin_date, user_create.end_date, vac_type )

			vac_id = db.query( 'SELECT LAST_INSERT_ID()' )[1]['LAST_INSERT_ID()']

			if user_create.comment then
				local get_vac_id = db.query( 'SELECT * FROM vacations WHERE user_id = ? AND begin = ? AND end = ?',
					params.userid, user_create.begin_date, user_create.end_date )[1].id

				db.query( 'INSERT INTO comments (user_id,vacation_id,comment) VALUES (?,?,?)',
					params.userid, get_vac_id, user_create.comment )

				com_id = db.query( 'SELECT LAST_INSERT_ID()' )[1]['LAST_INSERT_ID()']
			end


			action = 'Заявка № ' .. vac_id .. ' создана'

			db.query( 'INSERT INTO logs (user_id,vacation_id,comment_id,action,date_time) VALUES (?,?,?,?,NOW())',
				params.userid, vac_id, db.raw( com_id ), action )

			--print( 'fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff' )

			mail.send( params.userid, user_create.begin_date, user_create.end_date, vac_type, vac_id, check_cross, user_create.comment )

			return { json = { succecc = 'Заявка отправлена на рассмотрение администратору' } }
		end

		if #check_cross == 0 then
			return { json = { succecc = 'Нет пересечений с обладателями схожих компетенций' } }
		end
				
		return { json = { alert = check_cross } }
	end

	-- login
	-- { "token", "name", "userid", "email" }
	local function get_timestamp( str )
	
		local split = stringx.split( str )
		local date = stringx.split( split[1], '-' )
		local time = stringx.split( split[2], ':' )
	
		local dt = { year=date[1], month=date[2], day=date[3], hour=time[1], min=time[2], sec=time[3] }
	
		local tmstmp = os.time(dt)
	
		return tmstmp
	end

	--Данный енд поинт используется в более ранних версиях. Теперь это будет ундпоинт на выход.
	function userControllerProgged:get_user_login( params )
		local token = stringx.split( ngx.req.get_headers().authorization, ' ' )[2]

		db.query( 'DELETE FROM sessions WHERE access = ?', token )
		
		return { json = params }
	end

	-- get user info
	-- { "userid" }
	function userControllerProgged:get_user_get( params )

		--local token = stringx.split( ngx.req.get_headers().authorization, ' ' )[2]

		--print('GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG')
		--print( inspect( params ) )
		--print( util.unescape( params.name ) )
		
		local sel = db.query( 'SELECT * FROM users WHERE userid = ?', params.userid )[1]

		if not sel.id then
			return { json = { err = 'Такого пользователя не существует' } }
		end

		if sel.name ~= params.name or sel.email ~= params.email then
			db.query( 'UPDATE users SET name = ?, email = ? WHERE userid = ?', params.name, params.email, params.userid )
			return { json = { name = params.name, email = params.email, id = sel.id, isadmin = sel.isadmin } }
		else
			return { json = { name = sel.name, email = sel.email, id = sel.id, isadmin = sel.isadmin } }
		end
		--local info = db.query( [[SELECT u.name,u.email,u.id,s.access,u.isadmin FROM sessions s
		--	INNER JOIN users u ON s.client = u.userid WHERE s.access = ?]], token )
		
		--if #info == 0 then
		--	return { json = { err = 'Такого пользователя не существует' } }
		--else
		--	return { json = info[1] }
		--end
	end

	-- cancel vacation
	-- { "userid" }
	function userControllerProgged:post_user_vacation_cancel( params )
		-- код писать тут
		--local sel = db.query( 'SELECT * FROM vacations WHERE id = ? AND user_id = ?', params.param.vacid, params.userid )[1]
		local sel = db.query( 'SELECT * FROM vacations v INNER JOIN vac_type vc ON v.vac_type_id = vc.id WHERE v.id = ? AND v.user_id = ?',
			params.param.vacid, params.userid )[1]

		if not sel then
			return { json = { err = 'Такой заявки нет' } }
		end

		local com_id = 'NULL'

		db.query( 'UPDATE vacations SET status = "-2" WHERE id = ? AND user_id = ?', params.param.vacid, params.userid )

		if params.param.comment then
			db.query( 'INSERT INTO comments (user_id,vacation_id,comment) VALUES (?,?,?)',
				params.userid, params.param.vacid, params.param.comment )

			com_id = db.query( 'SELECT LAST_INSERT_ID()' )[1]['LAST_INSERT_ID()']
		end

		local action = 'Заявка № ' .. params.param.vacid .. ' отозвана автором'

		db.query( 'INSERT INTO logs (user_id,vacation_id,comment_id,action,date_time) VALUES (?,?,?,?,NOW())',
			params.userid, params.param.vacid, db.raw( com_id ), action )

		mail.cancel( params.userid, params.param.vacid, sel['begin'], sel['end'], sel.type )

		--local del = db.query( 'DELETE FROM vacations WHERE id = ? AND user_id = ?', params.param.vacid, params.userid )
		
		return { json = { sucess = 'Заявка отменена' } }
	end

	-- vacation list
	-- { "userid" }
	function userControllerProgged:get_user_list( params )
		-- код писать тут
		--local list = db.query( 'SELECT * FROM vacations WHERE ( (begin >= CURDATE() AND status = "1") OR status IS NULL ) AND user_id = ?', params.userid )
		local list = db.query( [[SELECT v.id,v.begin,v.end,v.status,v.user_id,DATEDIFF(v.end,v.begin)+1 counts,count(c.id) comments FROM vacations v
			LEFT JOIN comments c ON c.vacation_id = v.id
			WHERE ( (v.begin >= CURDATE() AND v.status = "1") OR v.status IS NULL ) AND v.user_id = ?
			GROUP BY v.id  ORDER BY v.id DESC]], params.userid )

		return { json = list }
	end

	-- vacation list
	-- { "userid" }
	function userControllerProgged:get_user_history( params )
		-- код писать тут
		--local list = db.query( 'SELECT * FROM vacations WHERE ( (begin < CURDATE() AND status IS NOT NULL) OR status IN ("-1","-2") ) AND user_id = ?', params.userid )
		local list = db.query( [[SELECT v.id,v.user_id,v.begin,v.end,v.status,DATEDIFF(v.end,v.begin)+1 counts,count(c.id) comments FROM vacations v 
			LEFT JOIN comments c ON c.vacation_id = v.id
			WHERE ( (v.begin < CURDATE() AND v.status IS NOT NULL) OR v.status IN ("-1","-2") ) AND v.user_id = ?
			GROUP BY v.id  ORDER BY v.id DESC]], params.userid )

		return { json = list }
	end

	-- set vacation comment
	-- { "userid", "token" }
	function userControllerProgged:post_user_comment( params )
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
	function userControllerProgged:get_user_comment( params )
		local sel = db.query( [[SELECT u.name, c.comment FROM comments c
							INNER JOIN users u ON c.user_id = u.id 
							WHERE c.vacation_id = ?]] , params.vacid )

		if #sel == 0 then
			return { json = { succecc = 'Никто не посчитал нужным комментировать эту заявку' } }
		end

		return { json = sel }
	end

	-- get count and vacation type
	-- { "userid", "clid" }
	function userControllerProgged:get_user_vacations( params )
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
