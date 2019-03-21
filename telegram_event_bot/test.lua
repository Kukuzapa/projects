local inspect   = require 'inspect'
local myreq     = require 'requests'
local date      = require 'date'
local urlencode = require 'urlencode'

local log       = require "log"
log.outfile     = './log/urllog.log'

local conf      = require 'config'

--Вспомогательная ф-ия.
local function get_data( str )
    if str then
        return str
    else
        return 'N/A'
    end
end
----END----

--УРЛ к нашей таблице
local spreadsheet_url = conf.spreadsheet_url .. conf.spreadsheet_id

--Запрос к АПИ. Таблица со всеми данными
local response = myreq.get( spreadsheet_url, { params = { key = conf.api_key, includeGridData = true } } ).json()

local fin = {}

--Сегодняшний день
local today = date():fmt('%d.%m')

--Список чатов (страниц таблицы с ид чатов)
local chats = response.sheets

--Колонки страниц
local columns = { 'date', 'event', 'text' }

--Идем по списку чатов и формируем таблицу
for _,chat in pairs( chats ) do

    chat_id = chat.properties.title

    fin[chat_id] = {}

    for _,data in pairs( chat.data[1].rowData) do
        
        local tmp = {}

        for i,val in pairs( data.values ) do
            if val.formattedValue then
                tmp[columns[i]] = val.formattedValue
            end
        end

        table.insert( fin[chat_id], tmp )
    end

end

--Идем по таблице и отправляем по совпадению дат
for i,v in pairs( fin ) do
    for j,u in pairs( v ) do
        if today == u.date then

            --local text = urlencode.encode_url( get_data( u.date ) .. ' ' .. get_data( u.event ) .. ' ' .. get_data( u.text ) )
	    local text = urlencode.encode_url( get_data( u.text ) )	

            local url = conf.telegram_api_url .. conf.event_bot_id .. '/sendMessage?chat_id=' .. i .. '&text=' .. text

            log.info( url )

            local response = myreq.post( 'https://queue.gtn.ee/queue/send_request', { json = {
                req_url = url, 
                method = "GET"
            } } )
        end
    end
end
