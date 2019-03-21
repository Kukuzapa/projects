local db     = require('lapis.db')
local myreq  = require 'requests'
local myreq  = require 'requests'
local tablex = require 'pl.tablex'
local stringx = require 'pl.stringx'

local conf   = require 'cron.tconf'

local command = {}


function command.test( tbl )

	local str1 = [[Это тест. 
	Это тест. Это тест. 
	Это тест. Это тест. Это тест.]]

	local str1 = 'sssssssssssssss'

	return stringx.replace( str1, '\n', '' )
end

function command.start( tbl )

	local sel, err = db.query( 'SELECT * FROM bot.clients WHERE telegram_user_id = ?', db.escape_literal( tbl.id ) )

	if #sel == 0 then
		db.query( 'INSERT INTO bot.clients (telegram_user_id,status) VALUES (?,?)', db.escape_literal( tbl.id ), 'w_name' )

		local str1 = 'Здравствуйте. Как вас зовут? Введите ваше имя и фамилию в формате "Имя Фамилия".'
		local str2 = ' Если вы ошиблись введите команду "/start" еще раз.'

		return str1 .. str2
	else 
		db.query( 'UPDATE bot.clients SET status = ?, telegram_user_name = NULL WHERE telegram_user_id = ?',
			'w_name', db.escape_literal( tbl.id ) )

		local str = 'Вы решили ввести имя по новому. Введите имя еще раз в формате "Имя Фамилия".'

		return str
	end
end


function command.status( tbl )

	local sel, err = db.query( 'SELECT * FROM bot.clients WHERE telegram_user_id = ?', db.escape_literal( tbl.id ) )

	if #sel == 0 then

		return 'Я вас не знаю.'
	else

		return sel[1].telegram_user_name .. ', мы с вами познакомились - ' .. sel[1].date_time
	end
end


function command.employees( tbl )

	local sel,err = db.query( [[SELECT * FROM bot.clients 
		WHERE telegram_user_id = ? AND status = ?]], db.escape_literal( tbl.id ) , 'admin' )

	if #sel == 0 then
		return 'такой команды нет'
	end

	local sel,err = db.query( [[SELECT * FROM bot.clients 
		WHERE telegram_user_name IS NOT NULL 
		AND ( status != ? OR status IS NULL )]], 'admin' )

	local response = myreq.get( conf.spreadsheet_url .. conf.spreadsheet_id .. '/values/1:1', { 
		params = { 
			key = conf.api_key, 
		} 
	} ).json().values[1]


	local tmp = ''

	for i,v in pairs( sel ) do
		if not tablex.find( response, v.telegram_user_name ) then
			tmp = tmp .. v.telegram_user_name .. ' '

			local url_test = conf.telegram_api_url .. conf.test_bot_id

			local url_poke = conf.telegram_api_url .. conf.poke_bot_id
			
			local text = v.telegram_user_name .. 
				' , вашего имени нет в списке сотрудников. Пожалуйста введите ваше имя по новому при помощи команды "/start".'

			local response = myreq.get( url_poke .. '/sendMessage', { params = { chat_id = v.telegram_user_id, text = text } } )

			local response = myreq.get( url_test .. '/sendMessage', { params = { chat_id = '305014237', text = text } } )
		end
	end

	return tmp
end


return command