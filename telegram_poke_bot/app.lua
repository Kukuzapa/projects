local lapis       = require("lapis")
local app         = lapis.Application()
local json_params = require("lapis.application").json_params
local util        = require("lapis.util")


local myreq   = require 'requests'

local inspect = require 'inspect'

local command = require 'module.command'
local message = require 'module.message'

local tablex  = require 'pl.tablex'
local stringx = require 'pl.stringx'
local db      = require('lapis.db')

local conf    = require 'cron.tconf'

local url_test = conf.telegram_api_url .. conf.test_bot_id

local url_poke = conf.telegram_api_url .. conf.poke_bot_id


app:get("/", function()
  	return "Welcome to Lapis " .. require("lapis.version")
end)

app:post( '/webhook', json_params( function( self ) 

	local request = self.params.message or self.params.edited_message

	local text 

	local chat_id = request.chat.id

	local file = io.open( 'mylog/log.log', 'a' )
	file:write( '\n' .. os.date() )
	file:write( '\n' .. inspect( request ) )
	file:close()

	--Проверяем наличие особых статусов сообщения
	if request.entities then
		for _,e in pairs( request.entities ) do
			print( inspect( e ) )
			--Это команда
			if e.type == 'bot_command' then
				local comm = stringx.split( string.lower( string.sub( request.text, 2 ) ), '@' )[1]

				if command[comm] then
					text = command[ comm ]( request.from )
				else
					text = 'Такой команды нет' 
				end
			end
		end
	end

	if not text then 
		--Проверим статус пациента. Возможно мы чего-то ждем.
		local status = db.query( 'SELECT * FROM bot.clients WHERE telegram_user_id = ?', db.escape_literal( request.from.id ) )

		if status and status[1] and message[status[1].status] then
			text = message[status[1].status]( request )
		else
			text = 'Вы общаетесь с ботом. Список команд можно увидеть при нажатии "/"'
		end
	end

	local response = myreq.get( url_poke .. '/sendMessage', { params = { chat_id = chat_id, text = text } } )

	local req_txt
	if request.text then
		req_txt = request.text
	else
		req_txt = 'something'
	end

	local response = myreq.get( url_test .. '/sendMessage', { params = { 
		chat_id = '305014237', 
		text = request.chat.first_name .. ' написал: ' .. req_txt .. ', а бот ответил: ' .. text 
	} } )

	return { json = response }
end) )

return app
