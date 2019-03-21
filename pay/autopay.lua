local conf    = require 'autopay.config'
local myreq   = require 'requests'
local inspect = require 'inspect'
local pgmoon  = require("pgmoon")

local pg, err  = pgmoon.new( conf.postgres )
local suc, err = pg:connect()

if err then
    print( os.date() .. ' ошибка соеденения с БД - ' .. err )
    return
end

local sel = pg:query( 'SELECT * FROM pay.tinkoff_reccurent_payment trp INNER JOIN pay.payments p ON trp.payment_id = p.id;' )

--print( inspect( sel ) )

local list = {}

local request = {}

for i,v in pairs( sel ) do

    table.insert( request, v.client_account_id )

    list[v.client_account_id] = { payment_id = v.payment_id, amount = v.amount, rebill_id = v.rebill_id, client = v.client_info }
end

--print( inspect( list ) )

local response = myreq.post( 'https://backend.gtn.ee/api/v1.0/account/client/batch', { json = request } ).json()

for i,v in pairs( response ) do

    if v.balance < 0 then
        list[v.uid].count = math.ceil( math.abs( v.balance ) / list[v.uid].amount )
    end

    if v.balance == 0 then
        list[v.uid].count = 1
    end

    --list[v.uid].count = 10
end

print( '-----------------------' .. os.date() .. '-----------------------' )

local charge = 0
--print( inspect( list ) )
for i,v in pairs( list ) do
    if v.count then
        charge = charge + v.count
        print( 'Пациент - ' .. v.client .. ', ' .. v.count .. ' платежей на ' .. v.amount .. ' каждый.' )
    end
end

print( 'Отправлено ' .. charge .. ' автоплатежей.' )

local response = myreq.post( conf.payment_url .. '/tinkoff/charge', { json = list } ).json()

--print( inspect( response ) )
for i,v in pairs( response ) do
    if v.ErrorCode ~= '0' then
        print( inspect( v ) )
        charge = charge - 1
    end
end

print( 'Успешно обработано ' .. charge .. ' платежей' )
