local lapis        = require("lapis")
local app          = lapis.Application()
local config       = require( "lapis.config" ).get()
local db           = require("lapis.db")
local json_params  = require("lapis.application").json_params
local util         = require("lapis.util")
local encoding     = require("lapis.util.encoding")

local uuid         = require("uuid")
local myreq        = require 'requests'
local sha1         = require "sha1"

local stringx      = require 'pl.stringx'
local tablex       = require 'pl.tablex'

local inspect      = require 'inspect'

local resty_sha256 = require "resty.sha256"
local resty_str    = require "resty.string"

--Вспомогательные функции
--Запись в лог
local function logger( tbl, filename )
	local file = io.open ( 'my_log/' .. filename, 'a' )
	file:write( os.date() .. '\n' )
	for i,v in pairs( tbl ) do
		file:write( i .. ': ' .. tostring( v ) .. '\n' )
	end
	file:write( '------------------------------------\n\n')
	file:close()
end

--Подсчет токена Тинькофф
local function get_tinkoff_token( tbl )
	local tmp = tablex.copy( tbl )
    local sha256 = resty_sha256:new()
    tmp.Password = config.tinkoff.password
    for key in tablex.sort( tmp ) do
    	if key ~= 'Token' then
			sha256:update( tostring( tmp[key] ) )
		end
	end
   	return resty_str.to_hex( sha256:final() )
end
----END----

--Обработка нотификаций
app:post("/tinkoff/notification", json_params( function( self )

	--Считаем токен по алгаритму Тинькоффа от полученного json-а
	local check = get_tinkoff_token( self.params )

	--Копируем json для записи в лог
	local notification = tablex.copy( self.params )

	--Добавим наш подсчитаный токен
	notification.check = check

	--Лог нотификации
	logger( notification, 'notification.log' )

	--Сравниваем наш и ихний) лог
	if check == self.params.Token then

		local sql = db.query( [[UPDATE pay.payments SET status = ?, bank_transaction_id = ? WHERE order_id = ? AND (status != 'CONFIRMED' or status IS NULL)]],
            self.params.Status, self.params.PaymentId, self.params.OrderId )

		logger( { sql = inspect( sql ) }, 'sql.log' )

		local sel = db.query( 'SELECT * FROM pay.payments WHERE order_id = ?', self.params.OrderId )[1]

		--Добавляем данные в реккурентные платежи
		if self.params.Status == 'AUTHORIZED' and self.params.RebillId then

			local client_info       = sel.client_info
			local client_account_id = sel.client_account_id
			local payment_id        = sel.id

			local sel = db.query( 'SELECT * FROM pay.tinkoff_reccurent_payment WHERE client_info = ?', client_info )

			if #sel == 0 then
				db.query( 'INSERT INTO pay.tinkoff_reccurent_payment (client_info,rebill_id,payment_id) VALUES(?,?,?)',
					client_info, self.params.RebillId, payment_id )
			else
				db.query( 'UPDATE pay.tinkoff_reccurent_payment SET rebill_id = ?, payment_id = ? WHERE client_info = ?',
					self.params.RebillId, payment_id, client_info )
			end
		end

		--Если платеж успешен
		if self.params.Status == 'CONFIRMED' then

			--Отправляем чек
			local url = 'https://www.dosgo.ru/external/OFD?id=%s&sum=%s&email=%s&hash=%s'

			local id    = sel.order_id
			local sum   = sel.amount
			local email = sel.client_email_phone
			local psw   = config.bill_psw
			local hash  = ngx.md5( id .. email .. sum .. psw )

			url = string.format( url, id, sum, email, hash )

			local response = myreq.get( url )

			logger( response, 'bill.log' )

			--Если ответ на чек ОК, отправляем в биллинг
			if response.text == 'OK' then

				local request = {
					["paymentsource"] = "f60656a6-0747-11e8-ad2e-875b46de56b8",            --Всегда Безналичный платеж
					["externalsid"]   = sel.bank_transaction_id,                           --Идентификатор транзакции банка
					["account"]       = sel.client_account_id,                             --Идентификатор пациента в нашей системе
					["currency"]      = '810',                                             --Рубли
					["ts"]            = sel.date_time,                                     --Дата и время платежа
					["amount"]        = sel.amount,                                        --Сумма
					["note"]          = "Проведение платежа через pay " .. sel.bank_name,  --Описалово
				}

				local response = myreq.post( 'https://backend.gtn.ee/api/v1.0/payment', { json = request } ).json()

				logger( response, 'kyc.log' )
			end
		end

		--Отправляем ответ подтвержения
		app:enable("etlua")
		app.layout = require "views.good_notification"
		self.options.status = 200
		return { render = 'good_notification' }
	end
end ) )



--Повторный запрос уведомлений
app:get( '/tinkoff/resend', function( self )

	local request = {
		TerminalKey = config.tinkoff.terminal_id,
	}

	request.Token = get_tinkoff_token( request )

	local response = myreq.post( 'https://securepay.tinkoff.ru/v2/Resend', { json = request } ).json()

	return { json = response }
end )

--Инициализация рекурентоного платежа
app:post( '/tinkoff/charge', json_params( function(self)

	local test = {}

	for i,v in pairs( self.params ) do

		local payment = db.query( [[SELECT * FROM pay.tinkoff_reccurent_payment trp
			INNER JOIN pay.payments p ON trp.payment_id = p.id
			WHERE trp.rebill_id = ? AND trp.payment_id = ?;]], v.rebill_id, v.payment_id )


		if v.count then
			for i=1,v.count do

				uuid.seed( os.time() )

				local request = {
					TerminalKey = config.tinkoff.terminal_id,
					Amount      = payment[1].amount * 100,
					OrderId     = uuid.new()
				}

				db.query( 'INSERT INTO pay.payments (order_id,amount,client_info,client_email_phone,bank_name,client_account_id) VALUES (?,?,?,?,?,?)',
					request.OrderId, payment[1].amount, payment[1].client_info, payment[1].client_email_phone, 'tinkoff', payment[1].client_account_id )

				local response = myreq.post( 'https://securepay.tinkoff.ru/v2/Init', { json = request } ).json()

				local charge = {
					TerminalKey = config.tinkoff.terminal_id,
					PaymentId = response.PaymentId,
					RebillId = v.rebill_id,
				}

				charge.Token = get_tinkoff_token( charge )

				local response = myreq.post( 'https://securepay.tinkoff.ru/v2/Charge', { json = charge } ).json()

				table.insert( test, response )
			end
		end

	end

	return { json = test }
end ) )


--Платеж Тиньофф
app:get("/tinkoff/pay", function( self )

	--dsdcdsc

	uuid.seed( os.time() )

	local request = {
		TerminalKey = config.tinkoff.terminal_id,
		Amount      = tonumber( stringx.replace( self.params.amount, ',', '.' ) ) * 100,
		OrderId     = uuid.new()
	}

	if self.params.recur then
		request.Recurrent = 'Y'
		request.CustomerKey = self.params.address
	end

	db.query( 'INSERT INTO pay.payments (order_id,amount,client_info,client_email_phone,bank_name,client_account_id) VALUES (?,?,?,?,?,?)',
		request.OrderId, self.params.amount, self.params.address, self.params.phone, 'tinkoff', self.params.uid )

	logger( request, 'request.log' )

	local response = myreq.post( 'https://securepay.tinkoff.ru/v2/Init', { json = request } ).json()

	return { json = response }
end)






--Обработка платежек на модуль-банк. Временно убранная
--[[app:get( '/module/pay', function( self )

	local secret_key = config.module.secret

	local request = {}

	local port = ''

	if self.req.parsed_url.port then
		port = ':' .. self.req.parsed_url.port
	end

	request.merchant        = config.module.merchant

	request.amount          = self.params.amount

	uuid.seed( os.time() )

	request.order_id        = uuid.new()

	request.description     = 'some description'

	request.success_url     = self.req.parsed_url.scheme .. '://' .. self.req.parsed_url.host
		.. port .. '/success/' .. request.order_id

	--request.success_url     = self.req.parsed_url.scheme .. '://' .. self.req.parsed_url.host .. ':'
	--	.. '8080' .. '/success/' .. request.order_id

	request.testing         = 1

	--request.fail_url        = 'https://pay.modulbank.ru/fail'
	request.fail_url        = self.req.parsed_url.scheme .. '://' .. self.req.parsed_url.host
		.. port .. '/fail/' .. request.order_id

	request.unix_timestamp  = os.time()

	local test = {}

	for key in tablex.sort( request ) do
		table.insert( test, key .. '=' .. encoding.encode_base64( request[key] ) )
	end

	local signature = table.concat( test, '&' )

	request.signature = sha1.sha1( secret_key .. string.lower( sha1.sha1( secret_key .. signature ) ) )

	db.query( 'INSERT INTO pay.payments (order_id,amount,client_info,client_email_phone,bank_name) VALUES(?,?,?,?,?)',
		request.order_id, request.amount, self.params.address, self.params.phone, 'module' )

	return { json = request }
end )]]

--СТАРЫЙ АПДЕЙТ СТАТУСОВ ПП. УБРАН, КАК МОРАЛЬНО НЕВЕРНЫЙ
--[[app:get( '/base', function( self )

	db.query( 'UPDATE pay.payments SET status = ?, bank_transaction_id = ? WHERE order_id = ?',
		self.params.status, self.params.transaction_id, self.params.order_id )

	if self.params.status == 'success' then
		local sel = db.query( 'SELECT * FROM pay.payments WHERE order_id = ?', self.params.order_id )[1]

		local url = 'https://www.dosgo.ru/external/OFD?id=%s&sum=%s&email=%s&hash=%s'

		local id    = sel.order_id
		local sum   = sel.amount
		local email = sel.client_email_phone
		local psw   = config.bill_psw
		local hash  = ngx.md5( id .. email .. sum .. psw )

		url = string.format( url, id, sum, email, hash )

		local response = myreq.get( url )

		logger( response, 'bill.log' )

		if response.text ~= 'OK' then
			return
		end

		local response = myreq.get( 'https://backend.gtn.ee/api/v1.0/account/client/list?number=' .. sel.client_info ).json()

		local request = {
			["paymentsource"] = "f60656a6-0747-11e8-ad2e-875b46de56b8",            --Всегда Безналичный платеж
			["externalsid"]   = sel.bank_transaction_id,                           --Идентификатор транзакции банка
			["account"]       = response[1].uid,                                   --Идентификатор пациента в нашей системе
			["currency"]      = '810',                                             --Рубли
			["ts"]            = sel.date_time,                                     --Дата и время платежа
			["amount"]        = sel.amount,                                        --Сумма
			["note"]          = "Проведение платежа через pay " .. sel.bank_name,  --Описалово
		}

		local response = myreq.post( 'https://backend.gtn.ee/api/v1.0/payment', { json = request } ).json()

		logger( response, 'kyc.log' )
	end

	return { json = { success = 'Статус платежа обновлен' } }
end )]]

--FRONT
app:match('layout',"/(*)", function( self )
	app:enable("etlua")
	app.layout = require "views.layout"
	self.res.headers[ "Content-Type" ] = "text/html; charset=utf-8"
	return { render = true }
end)
----END----

--Корс
app:before_filter( function( self )
	self.res.headers[ "access-control-allow-origin" ]      = config.access_control_allow_origin or "*"
	self.res.headers[ "access-control-max-age" ]           = config.access_control_max_age or 3600
	self.res.headers[ "access-control-allow-credentials" ] = config.access_control_allow_credentials or "true"
	self.res.headers[ "access-control-allow-headers" ]     = config.access_control_allow_headers or "Authorization, Content-Type, X-Requested-With"

	if self.req.cmd_mth == "OPTIONS" then
		self:write( {
			layout = false, headers = {
				["access-control-allow-methods"] = "GET,HEAD,POST",
			}
		} )
		return
	end
end )


function app:handle_error( err, trace )
	self:write( {
		json = {
			--error   = err,
			code    = 500,
			message = 'shit happens'
		},
		status = 500
	} )
end

return app
