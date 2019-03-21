-- Менеджер паролей
local db = require("lapis.db")
local inspect = require 'inspect'
local tablex = require 'pl.tablex'
local stringx = require 'pl.stringx'

local helpers = require 'module.helpers'

local http = require("lapis.nginx.http")
local util = require("lapis.util")

function func( tree, node )
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
	-- body
end
-- Отладка
local inspect = require( 'inspect' )

testControllerProgged = {}
function testControllerProgged:new( params )
	local private = {}
	local public = {}

	-- hello
	-- {}
	function testControllerProgged:get_hello( params )
		--Данные для кика моего приложения
		local client_id = '6192c9c2-a135-11e8-ba29-4f04e5ae533e'
		local client_secret = 'Ooshiece6kau'

		--ngx.say(inspect(params))
		
		local session = db.query( 'SELECT * FROM session WHERE access = ?', params.token )

		if #session > 0 then
			
			local tscreate = helpers.get_timestamp( session[1].tscreate )
			local now = os.time()

			if now - tscreate < session[1].expires_in then
				--ngx.say(now - tscreate)
				--ngx.say('Сессия жива и в работе')
				local user = db.query( 'SELECT * FROM users WHERE id = ?', session[1].client )
				return { json = { success = 'Сессия пользователя валидна', id = session[1].client, token = params.token, user = user[1].user } }
			else
				--ngx.say('сессия не валидна')
				--db.query( 'DELETE FROM session WHERE access = ?', params.token )
			end
		end

		--Получим токен апи
		local body, status_code, headers = http.simple("https://id.gtn.ee/oauth/token", {
			client_id = client_id,
			client_secret = client_secret,
			grant_type = "client_credentials"
		})

		if status_code ~= 200 then
			return { json = { err = 'Ошибка обращения к https://id.gtn.ee/oauth/token' } }
		end

		--Периодически падает, т.к. KYS выдает не json
		local access_token = util.from_json(body).access_token

		--Запросим данные по пользователю
		local body, status_code, headers = http.simple({
			url = "https://id.gtn.ee/oauth/introspect",
			method = "POST",
			headers = {
				["content-type"] = "application/x-www-form-urlencoded",
				["Authorization"] = "Bearer " .. access_token  
			},
			body = {
				token = params.token
			}
		})

		if status_code ~= 200 then
			return { json = { err = 'Ошибка обращения к https://id.gtn.ee/oauth/introspect' } }
		end
		
		local body = util.from_json(body)

		--ngx.say(inspect(body))

		local user
		--Сравним данные из куса и полученные
		if body.active then
			--Проверим наличие данного пользователя в нашей БД
			user = db.query( 'SELECT * FROM users WHERE userid = ? AND user = ?',
				body.client_id, body.username )

			--Добавим, если нет и дадим права на корень
			if #user == 0 then
				--ngx.say('Такого пользователя нет')
				db.query( 'INSERT INTO users (user,userid) VALUES (?,?)',
					body.username, body.client_id )
				user = db.query( 'SELECT * FROM users WHERE userid = ? AND user = ?',
					body.client_id, body.username )
				
				local node = db.query( 'SELECT node FROM nodes WHERE pid IS NULL')[1].node
				helpers.set_grants( 'users', user[1].id, node, 'pass' )
			end

			--Снесем сессию, если была данного пользователя
			db.query( 'DELETE FROM session WHERE client = ?', user[1].id )
			--Создадим сессию
			local tscreate = os.date('%Y-%m-%d %H:%M:%S', body.iat)
			local expires_in = body.exp - body.iat

			db.query( 'INSERT INTO session (access,tscreate,expires_in,client) VALUES (?,?,?,?)',
				params.token, tscreate, expires_in, user[1].id)
		else
			return { json = { err = 'Данные пользователя не найдены в KYS' } }
		end

		return { json = { success = 'Вход выполнен успешно', id = user[1].id, token = params.token, user = user[1].user } }
	end

	setmetatable( public, self )
	self.__index = self
	return public

end
