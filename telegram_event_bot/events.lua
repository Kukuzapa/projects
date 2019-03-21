--Отладка
local inspect = require 'inspect'



--либы паука
local fiber       = require 'fiber'
local http_client = require( "http.client" )
local json = require('json')
local log = require('log')

local fio = require 'fio'

local conf = require 'config'

--Сервер
local httpd   = require('http.server')
local server  = httpd.new( conf.server.host, conf.server.port )

box.cfg( conf.tarantool )

box.once( 'first_start', function()

    print('First time')
    
    box.schema.space.create('chat-list')

    box.space['chat-list']:format( {
        { name = 'chat_id', type = 'string' },
        { name = 'chat_name', type = 'string' }
    } )

    box.space['chat-list']:create_index( 'primary', { type = 'hash', parts = { 'chat_id' } } )

    box.space['chat-list']:create_index( 'secondary', { type = 'tree', parts = { 'chat_name' } } )

    box.space['chat-list']:insert( { '777', 'test' } )
    box.space['chat-list']:insert( { '555', 'fuck' } )

    local sel = box.space['chat-list']:select()

    print( inspect( sel ) )

    local sel = box.space['chat-list']:select( { '777' } )

    print( inspect( sel ) )

    local sel = box.space['chat-list'].index['secondary']:select( { 'fuck' } )

    print( inspect( sel ) )
end )

--Ловим сообщения от телеграма. Запоминаем пары идентификатор чата - имя чата
local function get_telegram_update()

    local offset

    while 1 == 1 do

        local url = conf.telegram_api_url .. conf.event_bot_id .. '/getUpdates'

        if offset then
            print( url .. '?offset=' .. offset )

            url = url .. '?offset=' .. offset
        end
        
        local response = json.decode( http_client.get( url ).body )

        if response.ok then
            
            response = response.result

            --дальше два стула. 1-ый - бота добавили в беседу. 2-ой - индивидуальный чат
            for _,resp in pairs( response ) do
                --обрабатывем стул 1
                if resp.message and resp.message.new_chat_member and resp.message.new_chat_member.id == 690445795 then
                    
                    local sel = box.space['chat-list']:select( { tostring( resp.message.chat.id ) } )

                    if #sel == 0 then
                        box.space['chat-list']:insert( { tostring( resp.message.chat.id ), resp.message.chat.title } )

                        log.info( os.date() .. ' ' .. 'добавлен новый чат/беседа ' .. resp.message.chat.title )
                    end
                end

                --второй стул. в данной ситуации точно была команда старт
                if resp.message and resp.message.entities and resp.message.entities[1].type == 'bot_command' and resp.message.text == '/start' then
                    
                    local sel = box.space['chat-list']:select( { tostring( resp.message.chat.id ) } )

                    if #sel == 0 then
                        box.space['chat-list']:insert( { tostring( resp.message.chat.id ), resp.message.chat.first_name } )

                        log.info( os.date() .. ' ' .. 'добавлен новый чат/беседа ' .. resp.message.chat.first_name )
                    end
                end

                offset = tostring( resp.update_id + 1 )
            end
        
            
        else
            log.error( os.date() .. ' ' .. response.error_code .. ': ' .. response.description )
        end

        fiber.sleep(1)
    end
end

--Список чатов. Гет запрос. Вспомогательный.
local function chat_list()

    local columns = { 'id', 'name' }

    local sel = box.space['chat-list']:select()

    local fin = {}

    for i,v in pairs( sel ) do
        table.insert( fin, { [columns[1]] = v[1], [columns[2]] = v[2] } )
    end

    return {
        status = 200,

        headers = { ['content-type'] = 'application/json; charset=UTF-8' },

        body = json.encode( fin )
    }
end

--Обработка хуков телеграма
function telegram_hook( req )

    --print( inspect( request:json() ) )



    --local response = json.decode( http_client.get( url ).body )

    local request = req:json()


    --print( inspect( request ) )

    
    --Есть два стула. 1-ый - бота добавили в беседу. 2-ой - индивидуальный чат
    
    --обрабатывем стул 1
    if request.message and request.message.new_chat_member and request.message.new_chat_member.id == 690445795 then
        
        local sel = box.space['chat-list']:select( { tostring( request.message.chat.id ) } )

        if #sel == 0 then
            box.space['chat-list']:insert( { tostring( request.message.chat.id ), request.message.chat.title } )

            log.info( os.date() .. ' ' .. 'добавлен новый чат/беседа ' .. request.message.chat.title )
        end
    end

    --второй стул. в данной ситуации точно была команда старт
    if request.message and request.message.entities and request.message.entities[1].type == 'bot_command' and request.message.text == '/start' then
        
        local sel = box.space['chat-list']:select( { tostring( request.message.chat.id ) } )

        if #sel == 0 then
            box.space['chat-list']:insert( { tostring( request.message.chat.id ), request.message.chat.first_name } )

            log.info( os.date() .. ' ' .. 'добавлен новый чат/беседа ' .. request.message.chat.first_name )
        end
    end
end


--fiber.create( get_telegram_update )



server:route( { path = '/chat_list',             method = 'GET'  }, chat_list )

server:route( { path = '/' .. conf.event_bot_id, method = 'POST' }, telegram_hook )

--server:start( conf.server.host, conf.server.port )

server:start()

local chmd = fio.chmod( '/tmp/eventbot.sock', tonumber('0666', 8))

--print( chmd )