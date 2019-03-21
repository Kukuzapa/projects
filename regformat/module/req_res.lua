local req_res = {}


--Модули ляписа
local db = require("lapis.db")

--Модули необходимые для отправки запроса
local https  = require "ssl.https"
local ltn12  = require "ltn12"
local ssl    = require "ssl"
local socket = require "socket"
local http   = require "socket.http"

--Обработка xml
local serde  = require 'module.xml.xml-serde'
local xmlser = require 'module.xml.xml-ser'

--Модули АПИ
local format = require "module.format"

--Сторонние модули
local stringx = require 'pl.stringx'
local lfs     = require 'lfs'

--Функция отправки команд
local function send( body, request_body, sesid )
	--timeout вызова
	http.TIMEOUT = 3
	--http.TIMEOUT = 0.0015
	
	local response_body = {}
	local res, code, response_headers = https.request{
  		url         = 'https://' .. body.host .. ':' .. body.port;
  		key         = body.key,
  		certificate = body.cert,
  		method      = "POST";
  		protocol    = "any",
  		options     = "all",
  		verify      = "none",
  		headers     = {
  			["Content-Length"] = string.len(request_body);
  			["Content-Type"]   = "text/xml; charset=UTF-8",
  			["User-Agent"]     = "EPP Client /1.0",
  			["Host"]           = body.host .. ':' .. body.port,
  			["Cookie"]         = sesid,
 		};
 		source = ltn12.source.string(request_body);
 		sink   = ltn12.sink.table(response_body);
 	}

 	local tableSpec, response, response_header, resp_code, response_xml

 	if response_body[1] and string.match( response_body[1], 'xml version' ) then

	 	tableSpec = serde.deserialize( response_body[1] )
	 	response = {}	
	 	
	 	format.response( tableSpec, response, body.reg )

	 	if #response.result == 1 then
			resp_code = response.result[1].code
		end

		response_xml = response_body[1]
	end

	if response_headers then
		response_header = response_headers['set-cookie']
	end

 	return response_header, code, tableSpec, response, response_xml, resp_code
end

--Отправляем xml строку и получаем xml ответ
function req_res.req( body, epp )

	local begin = '<?xml version="1.0" encoding="UTF-8"?>'

	if body.command == 'poll' or body.command == 'billing' then
		begin = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'
	end

	local response_header, tableSpec, response, response_xml, resp_code

	--Проверяем наличие активной сессии
	local file = io.open( lfs.currentdir() .. '/session/session.' .. body.reg , 'r' )
	
	if not file then
		lfs.mkdir( lfs.currentdir() .. '/session/' )
		--lfs.touch( lfs.currentdir() .. '/session/session.' .. body.reg )
		file = io.open( lfs.currentdir() .. '/session/session.' .. body.reg , 'w' )
	end
	
	local sesid = file:read()
	file:close()

	--Пишем лог, начало
	db.query('INSERT INTO queueTCI (object, command, id_registrars, date) VALUES (?,?,?,NOW())', body.obj, body.command, body.regid)
	local trid = db.query('SELECT last_insert_id()')[1]
	if trid then
		trid = trid['last_insert_id()']
	end

	--Напрямую запишем номер транзакции в финальную таблицу
	epp.kids[1].kids[2].text = body.reg .. '-' ..  trid

	local str = begin .. xmlser.serialize(epp)

	body.tr_status = 'work'

	db.query('UPDATE queueTCI SET request = ?, status = ? WHERE id = ?', str, body.tr_status, trid )
	--Печатает xml запрос, необходимо для отладки
	--ngx.say(str)

	--Отправкa и получение ответа
	response_header, code, tableSpec, response, response_xml, resp_code = send( body, str, sesid )

	--Если сессия с ТЦИ не была установлена или истекла, устанавливаем новую сессию и делаем повторный запрос
	if resp_code == '2501' then
		--ngx.say('Сессия просрочена, будем просить новую')
		--Считываем текущий пароль из БД
		local current_password = db.query( 'SELECT password FROM registrars WHERE registrar = ?', body.reg )
		--Если пароля нет, берет некий пароль из строки ниже, нужно в случае отсутствия пароля в БД
		if not current_password[1] then 
			current_password = 'fake_pass' 
		else
			current_password = current_password[1].password
		end

		--ngx.say(begin..xmlser.serialize(format.login(body.reg, current_password)))

		response_header, code, tableSpec, response, response_xml, resp_code = send( body, begin..xmlser.serialize(format.login(body.reg, current_password)) )

		--ngx.say(response_xml)
		
		--Если получили куку сессии пишем ее в таблицу для последующей работы
		if response_header then
			--ngx.say(response_header)
			local file = io.open( lfs.currentdir() .. '/session/session.' .. body.reg , 'w' )
			file:write( response_header )
			file:close()
		end

		response_header, code, tableSpec, response, response_xml, resp_code = send( body, str, response_header )

		--ngx.say(response_xml)
	end

 	--Пишем лог
 	if code ~= 200 then
 		response = {}
 		response.result = {}
 		response.result[1] = {}
 		response.result[1].code = 'CRITICAL ERROR'
 		response.result[1].msg = code
 		resp_code = 'timeout'
	end

 	if response then
		local result = ''
		local result_text = ''

		for i,v in pairs( response.result ) do
			result = result .. v.code .. ';'
			if v.reason then
				result_text = result_text .. v.msg .. ': ' .. v.reason .. ';'
			else
				result_text = result_text .. v.msg .. ';'
			end
		end

		if not response_xml then
			--or ( resp_code and tonumber(resp_code) > 2400 ) then
			body.tr_status = 'abort'
			local sql = 'UPDATE queueTCI SET result = "%s", result_text = "%s", trid = "%s", status = "%s" WHERE id = %s'
			sql = string.format( sql, stringx.strip( result, ';' ), stringx.strip( result_text, ';' ), body.clTRID, body.tr_status, trid )
			db.query( sql )
		else
			body.tr_status = 'done'
			local sql = 'UPDATE queueTCI SET result = "%s", result_text = ?, trid = "%s", response = ?, status = "%s" WHERE id = %s'
			sql = string.format( sql, stringx.strip( result, ';' ), body.clTRID, body.tr_status, trid )
			db.query( sql, stringx.strip( result_text, ';' ), string.gsub( response_xml, '\n', '' ) )
		end
	end

	--ngx.say(response_xml)

 	return response, tableSpec, resp_code, response_xml
end

--Отвечает на запрос типа hello, данный запрос имеет несколько другую структуру, нужен для пинга реестра
function req_res.hello( body, epp )
	
	local BEGIN         = '<?xml version="1.0" encoding="UTF-8"?>'
	local str           = BEGIN..xmlser.serialize(epp)
	ngx.say(str)
	local request_body  = str;
	local response_body = {}
	
	local res, code, response_headers = https.request{
  		url         = 'https://' .. body.host .. ':' .. body.port;
  		key         = body.key,
  		certificate = body.cert,
  		method      = "POST";
  		protocol    = "any",
  		options     = "all",
  		verify      = "none",
  		headers     = {
  			["Content-Length"] = string.len(request_body);
  			["Content-Type"]   = "text/xml; charset=UTF-8",
  			["User-Agent"]     = "EPP Client /1.0",
  			["Host"]           = body.host .. ':' .. body.port,
  			["Cookie"]         = sesid,
 		};
 		source = ltn12.source.string(request_body);
 		sink   = ltn12.sink.table(response_body);
 	}

 	local tableSpec

 	if response_body[1] and string.match( response_body[1], 'xml version' ) then

	 		tableSpec = serde.deserialize( response_body[1] )
	end

 	return tableSpec
end


--Заглушка, вернет то-же, что и отправляли, но в формате xml
function req_res.mock( epp )
	local BEGIN = '<?xml version="1.0" encoding="UTF-8"?>'

	local str = BEGIN .. xmlser.serialize(epp)

	ngx.say( str )
end

function req_res.poll( epp )
	local res = [[<?xml version="1.0" encoding="UTF-8"?>
		<epp xmlns="http://www.ripn.net/epp/ripn-epp-1.0"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="http://www.ripn.net/epp/ripn-epp-1.0 ripn-epp-1.0.xsd">
			<response>
				<result code="1000">
					<msg lang="ru">Команда выполнена успешно</msg>
				</result>
				<msgQ count="2" id="8886733">
					<qDate>2009-10-22T17:16:44.0Z</qDate>
					<msg lang="en">Transfer requested.</msg>
				</msgQ>
				<trID>
					<clTRID>ToolkitTest-1256217398212-49</clTRID>
					<svTRID>11693124</svTRID>
				</trID>
			</response>
		</epp>]]

	--На данном примере ответа из доков парсинг xml падает, как позже выяснилось отсутствовала одна из ">" в примере.
	local res1 = [[<?xml version="1.0" encoding="UTF-8" standalone="no"?>
		<epp xmlns="http://www.ripn.net/epp/ripn-epp-1.0"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="http://www.ripn.net/epp/ripn-epp-1.0 ripn-epp-1.0.xsd">
			<response>
				<result code="1301">
					<msg>Command completed successfully; ack to dequeue</msg>
				</result>
				<msgQ count="5" id="12345">
					<qDate>2000-06-08T22:00:00.0Z</qDate>
					<msg>Transfer requested.</msg>
				</msgQ>
				<resData>
					<obj:trnData
					xmlns:obj="http://www.ripn.net/epp/ripn-domain-1.0"
					xsi:schemaLocation="http://www.ripn.net/epp/ripn-domain-1.0 ripn-domain-1.0.xsd">
						<obj:name>example.su</obj:name>
						<obj:trStatus>pending</obj:trStatus>
						<obj:reID>ClientX</obj:reID>
						<obj:reDate>2000-06-08T22:00:00.0Z</obj:reDate>
						<obj:acID>ClientY</obj:acID>
						<obj:acDate>2000-06-13T22:00:00.0Z</obj:acDate>
						<obj:exDate>2002-09-08T22:00:00.0Z</obj:exDate>
					</obj:trnData>
				</resData>
				<trID>
					<clTRID>ABC-12345</clTRID>
					<svTRID>54321-XYZ</svTRID>
				</trID>
			</response>
		</epp>]]

	local res2 = [[<?xml version="1.0" encoding="UTF-8" standalone="no"?>
		<epp xmlns="http://www.ripn.net/epp/ripn-epp-1.0"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="http://www.ripn.net/epp/ripn-epp-1.0 ripn-epp-1.0.xsd">
			<response>
				<result code="1000">
					<msg>Command completed successfully</msg>
				</result>
				<msgQ count="4" id="12346"/>
				<trID>
					<clTRID>ABC-12346</clTRID>
					<svTRID>54322-XYZ</svTRID>
				</trID>
			</response>
		</epp>]]

	local res3 = [[<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="http://www.ripn.net/epp/ripnepp-1.0"
xmlns:xsi="http://www.w3.org/2001/XMLSchemainstance"
xsi:schemaLocation="http://www.ripn.net/epp/
ripn-epp-1.0 ripn-epp-1.0.xsd">
 <response>
 <result code="1000">
 <msg lang="ru">Команда выполнена
успешно</msg>
 </result>
 <resData>
 <domain:trnData
xmlns:domain="http://www.ripn.net/epp/ripndomain-1.0"
xsi:schemaLocation="http://www.ripn.net/epp/
ripn-domain-1.0 ripn-domain-1.0.xsd">
 <domain:name>cli18vkeityy2.ru</domain:name>
<domain:trStatus>pending</domain:trStatus>
 <domain:reID>TEST3-RU</domain:reID>
 <domain:reDate>2016-06-
22T17:00:38.0Z</domain:reDate>
 <domain:acID>TEST2-RU</domain:acID>
 <domain:acDate>2016-07-
12T17:00:38.0Z</domain:acDate>
 </domain:trnData>
 </resData> <trID>
 <clTRID>Domain::Transfer-20160622-
195951</clTRID>
 <svTRID>3070469024</svTRID>
 </trID></response></epp>]]

 	res4 = [[<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="http://www.ripn.net/epp/ripn-epp-1.0">
<response>
<result code="1000">
<msg>Command completed successfully</msg>
</result>
<resData>
<billing:infData xmlns:billing="http://www.tcinet.ru/epp/tci-billing-1.0">
<billing:balance>
<billing:sum>10000.00</billing:sum>
<billing:credit>800.00</billing:credit>
<billing:calcDate>2016-04-19T12:43:51.0Z</billing:calcDate>
</billing:balance>
</billing:infData>
</resData>
<trID>
<clTRID>ABC-12345</clTRID>
<svTRID>54322-XYZ</svTRID>
</trID>
</response>
</epp>]]

	local resp = {}


	local tableSpec = serde.deserialize( res1 )

	format.response(tableSpec,resp)

	return tableSpec, resp, res1
end

return req_res