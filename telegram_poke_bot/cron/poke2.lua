local inspect = require 'inspect'
local date    = require 'date'
local myreq   = require 'requests'
local tablex  = require 'pl.tablex'

--БД
local pgmoon  = require("pgmoon")
local conf    = require 'tconf'
local pg      = pgmoon.new( conf.postgres )


local spreadsheet_url = conf.spreadsheet_url .. conf.spreadsheet_id

--Запрос к АПИ. Таблица со всеми данными
local response = myreq.get( spreadsheet_url, { params = { key = conf.api_key, includeGridData = true } } ).json()

--Дата в формате SERIAL_NUMBER. Т.е кол-во дней с 30.12.1899. Это и будем искать.
local zero_date = date(1899,12,30)
--Завтрашня дата в формать сериал нумбер ее и будем искать или больше
local tomr_date = date.diff(date(date():getyear(),date():getmonth(),date():getday()), zero_date):spandays() + 1

--Название завтрашнего дня
local tomr_day  = 'ukn'

--Наша таблица
local row_data = response.sheets[1].data[1].rowData

local rows    = {} -- Номера нужных строк
local count   = 0 -- Счетчик
local columns = {} -- Список колонок


--По первой строке формируем таблицу колонок
for i,v in pairs( row_data[1].values ) do
	table.insert( columns,v.formattedValue )
end


for i=2,#row_data do
	
	--Идем по таблице. Когда видим завтрашний день или день больше завтрашнего( вариант разрыва ) добавляем его и увеличивыем счетчик
	if tomr_date == row_data[i].values[1].effectiveValue.numberValue or tomr_date < row_data[i].values[1].effectiveValue.numberValue then
		table.insert( rows, i )
		count = count + 1
	end

	--Когда счетчик равен 2, т.е. утро и вечер выходим из цикла и получаем название нужного дня.
	if count == 2 then
		tomr_day = zero_date:adddays( tonumber( row_data[i].values[1].effectiveValue.numberValue ) ):fmt( '%a' )
		break
	end

end

local employees = {}

local this_is_no_names = { 'утро/вечер', 'неделя', 'Дата', 'check', 'День' } --Это точно не имена

local send_list = {} --Сообщения для рассылки ботом

--Формируем список сотрудников
for i,v in pairs( columns ) do
	if not tablex.find( this_is_no_names, v ) then
		table.insert( employees, v )
	end
end


--Словари
local days = {
	['Mon'] = 'в понедельник',
	['Tue'] = 'во вторник',
	['Wed'] = 'в среду',
	['Thu'] = 'в четверг',
	['Fri'] = 'в пятницу',
	['Sat'] = 'в субботу',
	['Sun'] = 'в воскресение',
	['ukn'] = 'не определено'
}
local part_day = {
	['У'] = 'УТРОМ',
	['В'] = 'ВЕЧЕРОМ'
}


--Формируем записи
for _,row in pairs( rows ) do
	
	local tmp = {}
	
	for i,v in pairs( row_data[row].values ) do
		if v.formattedValue then
			tmp[columns[i]] = v.formattedValue
		else
			tmp[columns[i]] = '0'
		end
	end

	local str = 'Добрый вечер, %s, завтра (' .. days[tomr_day] .. ') вы работаете ' .. part_day[tmp['утро/вечер']] .. ' %s часов'

	for i,v in pairs( employees ) do
		if tmp[v] ~= '0' and tonumber( tmp[v] ) then
			if send_list[v] then
				send_list[v] = send_list[v] .. ' и ' .. part_day[tmp['утро/вечер']] .. ' ' .. tmp[v] .. ' часов'
			else
				send_list[v] = string.format( str, v, tmp[v] )
			end
		end
	end
end


pg:connect()

local sel,err = pg:query( "SELECT * FROM bot.clients WHERE telegram_user_name IS NOT NULL AND ( status != 'admin' OR status IS NULL )" )

for i,v in pairs( sel ) do

	--Мой тестовый бот
	local url_test = conf.telegram_api_url .. conf.test_bot_id

	--Бот покешной
	local url_poke = conf.telegram_api_url .. conf.poke_bot_id


	if not tablex.find( employees, v.telegram_user_name ) then

		local text = v.telegram_user_name .. 
			' , вашего имени нет в списке сотрудников. Пожалуйста введите ваше имя по новому при помощи команды "/start".'

		--Покешный. Отправляет сотруднику
		local response = myreq.get( url_poke .. '/sendMessage', { params = { chat_id = v.telegram_user_id, text = text } } )

		--Копия мне
		local response = myreq.get( url_test .. '/sendMessage', { params = { chat_id = '305014237', text = text } } )
	end	


	if send_list[v.telegram_user_name] then

		local text = send_list[v.telegram_user_name]

		--Уведомление сотруднику.
		local response = myreq.get( url_poke .. '/sendMessage', { params = { chat_id = v.telegram_user_id, text = text } } )
		
		--Копия Нику
		local response = myreq.get( url_poke .. '/sendMessage', { params = { chat_id = '134488061', text = text } } )

		--Копия мне.
		local response = myreq.get( url_test .. '/sendMessage', { params = { chat_id = '305014237', text = text } } )	
	end

end
