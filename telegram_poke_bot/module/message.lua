local db      = require('lapis.db')
local stringx = require 'pl.stringx'
local myreq   = require 'requests'
local tablex  = require 'pl.tablex'

local conf    = require 'cron.tconf'

local message = {}

function message.w_name( tbl )

	local name = stringx.strip( tbl.text )

	local sel = db.query( 'SELECT * FROM bot.clients WHERE telegram_user_name = ?', name )

	if #sel > 0 then
		return 'Это имя уже присутствует в списке. Пожалуйста введите другое имя.'
	end

	--Запрос к АПИ
	local response = myreq.get( conf.spreadsheet_url .. conf.spreadsheet_id .. '/values/1:1', { 
		params = { 
			key = conf.api_key, 
		} 
	} ).json().values[1]

	local it_is_no_name = { 'утро/вечер', 'неделя', 'Дата', 'check', 'День' }

	if not tablex.find( response, name ) or tablex.find( it_is_no_name, name ) then
		return 'Сотрудник с таким именем неизвестен. Введите имя еще раз в формате "Имя Фамилия".'
	end


	db.query( 'UPDATE bot.clients SET status = NULL, telegram_user_name = ? WHERE telegram_user_id = ?', 
		name, db.escape_literal( tbl.from.id ) )

	return 'Приятно познакомится с вами, ' .. name
end



return message