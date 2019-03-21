local http  = require "resty.http"
local httpc = http.new()
local date  = require 'date'
local cjson = require "cjson"
local inspect = require 'inspect'


local function get_headers( sid )
	return {
		["content-type"] = "application/json-rpc;charset=utf-8",
		['Accept'] = '*/*, application/json-rpc',
		['X-SBISSessionID'] = sid
	}
end


local request = {}

	--Получить бинарник файла
	function request.binary( sid, url, xml )
		
		local res, err = httpc:request_uri( url, {
			headers = get_headers( sid ),
			method = 'GET',
			ssl_verify = false
		})

		if err then
			return {
				body = {
					error = {
						details = 'Ошибка соеденения - ' .. err
					}
				},
				status = 422
			}	
		end

		if xml then
			local iconv = require("iconv")

			local cd = iconv.new('utf8','cp1251')

			local nstr, err = cd:iconv(res.body)

			res.body = nstr
		end

		return res
	end

	--Отправка запроса, за исключением аутотентификации
	function request.send( sid, req )

		local URL = 'https://online.sbis.ru/service/?srv=1'

		local res, err = httpc:request_uri( URL, {
			headers = get_headers( sid ),
			method = 'POST',
			body = cjson.encode( req ),
			ssl_verify = false
		})

		if err then
			return {
				body = {
					error = {
						details = 'Ошибка соеденения - ' .. err
					}
				},
				status = 422
			}	
		end

		res.body = cjson.decode( res.body )

		return res
	end

	--Функция аутентификации
	function request.auth( sid, req )
		local count = 1 
		local status = '401'
		local res, err

		--Пробуем 5 раз. Возможно что это и не нужно
		while status == '401' and count < 5 do
			res, err = httpc:request_uri( 'https://online.sbis.ru/auth/service/', {
				headers = {
					["content-type"] = "application/json-rpc;charset=utf-8",
					['Accept']       = '*/*, application/json-rpc'
				},
				method = 'POST',
				body = cjson.encode( req ),
				ssl_verify = false
			})

			count = count + 1

			if err then
				break
			else
				status = res.status
			end
		end

		if err then
			return {
				body = {
					error = {
						details = 'Ошибка соеденения - ' .. err
					}
				},
				status = 422
			}		
		end

		res.body = cjson.decode( res.body )

		return res
	end
		
return request