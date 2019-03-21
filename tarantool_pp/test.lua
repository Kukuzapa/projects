box.cfg{
    memtx_dir = 'snap_xlog',
    wal_dir   = 'snap_xlog',
}
--Модули тарантула и сторонние
local inspect     = require 'inspect'
local cjson       = require 'cjson'
local stringx     = require 'pl.stringx'
local uuid        = require("uuid")
local tablex      = require 'pl.tablex'
local inspect     = require 'inspect'
local fiber       = require 'fiber'
local http_client = require( "http.client" )
local digest      = require( "digest" )

--Модули мои
local valid       = require 'module.vlaidate'


--Константы приложения
local URL  = 'http://directbank.gtn.ee:8815/api/v1.0/'             -- урл директбанка
local LOG  = 'api'                                                 -- логин для директбанка
local PAS  = 'get-net12345'                                        -- пароль для директбанка
local AUTH = 'Basic ' .. digest.base64_encode( LOG .. ':' .. PAS ) -- заголовок аутентификации для директбанка

--Сервер тарантула
local httpd   = require('http.server')
local server  = httpd.new('0.0.0.0', 8080)

--[[local std_columns = { 
    "DOCNO", "DOCDATE", "SUM", 
    "PAYER_NAME", "PAYER_INN", "PAYER_KPP", "PAYER_ACCOUNT", 
    "PAYER_BANK_BIC", "PAYER_BANK_NAME", "PAYER_BANK_CITY", 
    "PAYER_BANK_CORRESPACC", "PAYEE_NAME", "PAYEE_INN", "PAYEE_KPP", 
    "PAYEE_ACCOUNT", "PAYEE_BANK_BIC", "PAYEE_BANK_NAME", "PAYEE_BANK_CITY", 
    "PAYEE_BANK_CORRESPACC", "PAYMENTKIND", "TRANSITIONKIND", 
    "PRIORITY", "CODE", "PURPOSE", "PAYID", "EXCID", "STATUS" 
}]]

box.once( 'first_start', function()
    local start_t = require 'module.start_t'
    
    print('Hello')

    --print( start_t.pay )

    box.sql.execute( start_t.pay )

    start_t.bic()

    start_t.kbk()

    start_t.oktmo()

end )

--local start_t = require 'module.start_t'
    
--print('Hello')

--print( start_t.pay )

--PRETTY SELECT
local function pretty_select( sel )
    local fin = {}

    for i=1,#sel do
        local tmp = {}

        for j,v in pairs( sel[0] ) do
            if type(sel[i][j]) ~= 'cdata' then
                tmp[v] = sel[i][j]
            end
        end

        table.insert( fin, tmp )
    end

    return fin
end

--Запись платежки в БД
local function paydoc( request )

    local tmp = request:json()
    
    tmp.payid = uuid.str()

    local sql = 'INSERT INTO pay (%s) VALUES (%s);'

    local var = {}
    local val = {}
    
    for i,v in pairs( tmp ) do
        table.insert( var, i )
        table.insert( val, "'" .. v .. "'" )
    end

    var = table.concat( var, ',' )
    val = table.concat( val, ',' )

    sql = string.format( sql, var, val )

    box.sql.execute( sql )

    return {
        status = 200,
        body = cjson.encode( {
            sql = sql,
            status = 'add to DB',
            doc_id = tmp.payid
        } )
    }
end

--Список всех ПП
local function getdoc( request )
    return {
        status = 200,
        body = cjson.encode( pretty_select( box.sql.execute( 'SELECT * FROM pay;' ) ) )
    }
end

--Формирование страницы окна информации о ПП
local function info( request )
    local id = request:stash( 'id' )

    local pretty = pretty_select( box.sql.execute( [[SELECT * FROM pay WHERE payid =']] .. id .. [[';]]) )[1]

    return request:render({ user = cjson.encode( pretty ), status = pretty.STATUS or 'wait', usr = pretty })
end

--fiber валидации. Всегда крутится с паузой в 1 секунду.
local function fiber_validate()

    while 1 == 1 do
        --выбираем все документы без статуса
        local select = pretty_select( box.sql.execute( [[SELECT * FROM pay WHERE status IS NULL;]] ) )

        --идем по посписку выбранных документов
        for _,sel in pairs( select ) do

            local status = 'accept'

            --Список необходимых полей
            local std_field = { "DOCNO", "DOCDATE", "SUM", "PURPOSE", "PAYER_NAME", "PAYER_BANK_BIC", "PAYEE_NAME",
                "PAYEE_BANK_BIC", 'PAYER_BANK_CORRESPACC', 'PAYEE_BANK_CORRESPACC', 'PAYER_ACCOUNT', 'PAYEE_ACCOUNT' }

            --Список валидируемых полей
            local val = { 'DOCNO', 'PAYER_INN', 'PAYEE_INN', 'DOCDATE', 'PAYEE_BANK_BIC', 'PAYER_BANK_BIC', 
                'PAYER_BANK_CORRESPACC', 'PAYEE_BANK_CORRESPACC', 'TRANSITIONKIND', 'SUM', 'PAYER_ACCOUNT', 'PAYEE_ACCOUNT' }

            --Если ПП в бюджет добавляем в списки новые поля
            if sel['IS_BUDGET'] then
                local bdg = { 'B_KBK', 'B_REASON', 'B_TAXPERIOD', 'B_DRAWERSTATUS', 'B_PAYTYPE', 'B_DOCNO', 'B_DOCDATE', 'B_OKTMO' }

                for _,v in pairs( bdg ) do
                    table.insert( std_field, v )
                    table.insert( val, v )
                end
                --table.insert( std_field, 'B_KBK' )
                --table.insert( val, 'B_KBK' )
            end

            --Проверка наличия обязательных
            for _,v in pairs( std_field ) do
                if not sel[v] then
                    status = 'reject ' .. v
                    break
                end
            end
            
            --Валидация
            print( inspect( val ) )
            if status == 'accept' then
                for i,v in pairs( sel ) do
                    if tablex.find( val, i ) then
                        print( i )
                        if not valid[i]( sel, i ) then
                            --print( i, ' ', v )
                            status = 'reject val err ' .. i
                            break 
                        end
                    end
                end
            end

            --Обновляем статус документа, формируем запрос sql и выполняем его
            local sql = [[UPDATE pay SET status =']] .. status ..[[' WHERE payid = ']] .. sel['PAYID'] .. [[';]]

            box.sql.execute( sql )
        end

        fiber.sleep(1)
    end
end

--Список всех БИКОВ банков в БД
local function getbic()

    local sel = box.sql.execute( [[SELECT * FROM bic;]] )

    local fin = {}
    
    for i,v in pairs( sel ) do
        table.insert( fin, { bic = v[1], name = v[2] } )
    end
    
    return {
        status = 200,
        body = cjson.encode( fin )
    }
end

--Тестовая хрень
local function test()

    --local sel = box.sql.execute( [[SELECT * FROM pay WHERE status = 'accept';]] )

    --print( inspect( sel ) )
    
    box.sql.execute( [[CREATE TABLE kbk_admn (
        kbk VARCHAR(30),
        name VARCHAR(250),
        ppo VARCHAR(30),
        status VARCHAR(20)
    );]] )

    return {
        status = 200,
        body = cjson.encode( { message = 'УРА!' } )
    }
end
----КОНЕЦ ТЕСТОВОЙ ХРЕНИ----

--Поток обмена ПП с директ банком
local function fiber_send()

    while 1 == 1 do

        local sel = box.sql.execute( [[SELECT * FROM pay WHERE status = 'accept';]] )

        local pretty = pretty_select( sel )

        for i,v in pairs( pretty ) do
            local json_to_send = {
                ["DocNo"]   = v.DOCNO,
                ["DocDate"] = v.DOCDATE,
                ["Sum"]     = v.SUM,
                ["Payer"]   = {
                    ["Name"]    = v.PAYER_NAME,
                    ["INN"]     = v.PAYER_INN,
                    ["KPP"]     = v.PAYER_KPP,
                    ["Account"] = v.PAYER_ACCOUNT,
                    ["Bank"]    = {
                        ["BIC"]        = v.PAYER_BANK_BIC,
                        ["Name"]       = v.PAYER_BANK_NAME,
                        ["City"]       = v.PAYER_BANK_CITY,
                        ["CorrespAcc"] = v.PAYER_BANK_CORRESPACC
                    }
                },
                ["Payee"] = {
                    ["Name"]    = v.PAYEE_NAME,
                    ["INN"]     = v.PAYEE_INN,
                    ["KPP"]     = v.PAYEE_KPP,
                    ["Account"] = v.PAYEE_ACCOUNT,
                    ["Bank"]    = {
                        ["BIC"]        = v.PAYEE_BANK_BIC,
                        ["Name"]       = v.PAYEE_BANK_NAME,
                        ["City"]       = v.PAYEE_BANK_CITY,
                        ["CorrespAcc"] = v.PAYEE_BANK_CORRESPACC
                    }
                },
                ["PaymentKind"]    = v.PAYMENTKIND,
                ["TransitionKind"] = v.TRANSITIONKIND,
                ["Priority"]       = v.PRIORITY,
                ["Code"]           = v.CODE,
                ["Purpose"]        = v.PURPOSE
            }

            if v.IS_BUDGET then
                json_to_send['BudgetPaymentInfo'] = {
                    ['DrawerStatus'] = v.B_DRAWERSTATUS,
                    ['CBC']          = v.B_KBK,
                    ['OKTMO']        = v.B_OKTMO,
                    ['Reason']       = v.B_REASON,
                    ['TaxPeriod']    = v.B_TAXPERIOD,
                    ['DocNo']        = v.B_DOCNO,
                    ['DocDate']      = v.B_DOCDATE,
                    ['PayType']      = v.B_PAYTYPE
                }
            end

            local response = http_client.post(
                URL .. 'request/tochka/paydoc',
                cjson.encode( json_to_send ), 
                {
                    headers = {
                        [ 'Accept' ]        = 'application/json',
                        [ 'Content-Type' ]  = 'application/json',
                        [ 'Authorization' ] = AUTH
                    }
                }
            )

            --print( inspect( response ) )

            local body = cjson.decode( response.body )

            if body.success then
                box.sql.execute( [[UPDATE pay SET status = 'send to redirect', excid = ']] .. body.ret .. [[' WHERE payid = ']] .. v.PAYID .. [[';]] )
            else
                box.sql.execute( [[UPDATE pay SET status = 'error send to redirect' WHERE payid = ']] .. v.PAYID .. [[';]] )
            end
        end

        local pretty = pretty_select( box.sql.execute( [[SELECT * FROM pay WHERE status = 'send to redirect';]] ) )

        for i,v in pairs( pretty ) do

            local response = http_client.get(
                URL .. 'request/tochka/statusrequest/' .. v.EXCID, 
                {
                    headers = {
                        [ 'Authorization' ] = AUTH
                    }
                }
            )
            
            local body = cjson.decode( response.body )

            if body.success then
                box.sql.execute( [[UPDATE pay SET status = 'good from redirect' WHERE payid = ']] .. v.PAYID .. [[';]] )
            else
                box.sql.execute( [[UPDATE pay SET status = 'bad from redirect' WHERE payid = ']] .. v.PAYID .. [[';]] )
            end

        end

        fiber.sleep(1)
    end
end

--Запуск потоков
fiber.create( fiber_validate )
fiber.create( fiber_send )

--Страница фронта ввода ПП
server:route( { path = '/', file = 'index.html' } )

--JSON пишем ПП в БД
server:route( { path = '/paydoc' }, paydoc )

--Список ПП из БД
server:route( { path = '/getdoc' }, getdoc )

--Страница фронта для ПП по ид со статусом
server:route( { path = '/info/:id', file = 'info.html' }, info )

--Список БИК банков
server:route( { path = '/bic' }, getbic )

--Тестовый роут
server:route( { path = '/test' }, test )

local function kbk_code()
    return {
        status = 200,
        body = cjson.encode( pretty_select( box.sql.execute( 'SELECT * FROM kbk_code;' ) ) )
    }
end

local function kbk_admn()
    return {
        status = 200,
        body = cjson.encode( pretty_select( box.sql.execute( 'SELECT * FROM kbk_admn;' ) ) )
    }
end

local function oktmo()
    return {
        status = 200,
        body = cjson.encode( pretty_select( box.sql.execute( 'SELECT * FROM oktmo;' ) ) )
    }
end

server:route( { path = '/oktmo' }, oktmo )
server:route( { path = '/kbk_code' }, kbk_code )
server:route( { path = '/kbk_admn' }, kbk_admn )

server:start()