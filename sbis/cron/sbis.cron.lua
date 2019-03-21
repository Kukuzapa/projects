--Библиотека постгрес
local pg = require("resty.postgres")
--Конфигурация
local conf = require 'postgres_conf'
--Работа с json
local cjson = require "cjson"
--Сторки
local stringx = require 'pl.stringx'
--Шаблоны
local templ = require 'templates'

local db = pg:new()
local ok, err = db:connect( conf.postgres )

local request = require 'request'
--Не достучались до БД
if not ok then
    print( os.date('%c',os.time()) .. ': Ошибка соеденения с БД - ' .. err )
    return
end

local function wrapper( command, body )

    local sid = db:query( 'SELECT session FROM session' )[1].session

    local req = templ[command]( body, conf.getnet.inn, conf.getnet.kpp )

    local log_id = db:query( string.format( "INSERT INTO log (req_method,req_params,req_time,doc_id) VALUES ('%s','%s',NOW(),'%s') RETURNING id",
        req["method"], cjson.encode( req.params ), body.id ) )[1].id

    local res = request.send( sid, req )

    if res.status == 401 then
        local areq = templ.auth( conf.getnet.login, conf.getnet.pass )

        local auth = request.auth( sid, areq )

        if auth.status == 200 then
            db:query( string.format( "UPDATE session SET session = '%s',updated = NOW() WHERE session = '%s'", auth.body.result, sid ) )
            res = request.send( auth.body.result, req )
            print( os.date('%c',os.time()) .. ': Запрос нового идентификатора сессии - успешно' )
        else
            print( os.date('%c',os.time()) .. ': Запрос нового идентификатора сессии - фиаско' )
        end
    end

    local response
    
    if res.body.error then
        response = cjson.encode( res.body.error )
    else
        response = cjson.encode( res.body.result )
    end

    response = stringx.replace( response, "'", "" )

    db:query( string.format( "UPDATE log SET res_status = '%s', res_body = '%s' WHERE id = %s", res.status, response, log_id ) )

    return res.body
end

local sel,err = db:query( string.format( "SELECT * FROM requests WHERE status = '%s'", 'process' ) )

for i,v in pairs( sel ) do
    local tmp = cjson.decode( v.request )

    --Запрос информации о контрагенте
    local partner = wrapper( 'partner', tmp )

    local res_status, res_response

    if partner.result then
        if partner.result["Идентификатор"]:len() > 0 then
            --формирование запроса
            local prepare = wrapper( 'prepare', tmp )

            if prepare.result then
                --Отправляем контрагенту
                local send = wrapper( 'send', tmp )

                if send.result then
                    res_status = 'success'
                    res_response = 'Документ отправлен контрагенту'
                else
                    res_status = 'error'
                    res_response = 'Ошибка отправки докуента - ' .. send.error.details
                end

            else
                res_status = 'error'
                res_response = 'Ошибка подготовки документаc - ' .. prepare.error.details
            end
        else
            res_status = 'alert'
            res_response = 'Данный контрагент не имеет ЭДО в системе СБИС'
        end
    else
        res_status = 'error'
        res_response = 'Ошибка поиска контрагента - ' .. partner.error.details
    end

    res_response = stringx.replace( res_response, "'", "" )
    
    local upd,err = db:query( string.format( "UPDATE requests SET status = '%s', response = '%s', date_res = NOW() WHERE id = '%s'",
        res_status, res_response, v.id ) )
end

print( os.date('%c',os.time()) .. ': Крон отработал' )