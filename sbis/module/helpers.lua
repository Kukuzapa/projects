local db = require("lapis.db")
local http     = require("lapis.nginx.http")
local cjson    = require 'cjson'
local stringx = require 'pl.stringx'
local requests = require 'requests'
local pathx    = require 'pl.path'
local tablex = require 'pl.tablex'
local iconv    = require("iconv")

local help = {}

--Обертка для обмена со СБИС
function help.wrapper( command, req )
    --Берем сессия ид
	local sid = db.query( 'SELECT * FROM session')[1].session
	
	local headers = {
		["content-type"] = "application/json-rpc;charset=utf-8",
		['Accept'] = '*/*, application/json-rpc',
		['X-SBISSessionID'] = sid
	}

	local resp,stat,head = http.simple({
		url = "https://online.sbis.ru/service/?srv=1",
		method = "POST",
		headers = headers,
		body = cjson.encode( req )
	})

    if stat == 401 then
		
		local areq = {
            ["jsonrpc"] = "2.0",
            ["method"]  = "СБИС.Аутентифицировать",
            ["params"]  = {
                ["Логин"]  = config.getnet.login,
                ["Пароль"] = config.getnet.pass
            },
            ["id"] = 0
        }

        local ar, as, ah = http.simple({
			url = "https://online.sbis.ru/auth/service/",
			method = "POST",
			headers = {
				["content-type"] = "application/json-rpc;charset=utf-8",
				['Accept']       = '*/*, application/json-rpc'
			},
			body = cjson.encode( areq )
		})

		if as == 200 then
			db.query( 'UPDATE session SET session = ?, updated = NOW() WHERE session = ?', cjson.decode( ar ).result, sid )

			resp,stat,head = http.simple({
				url = "https://online.sbis.ru/service/?srv=1",
				method = "POST",
				headers = {
					["content-type"] = "application/json-rpc;charset=utf-8",
					['Accept'] = '*/*, application/json-rpc',
					['X-SBISSessionID'] = cjson.decode( ar ).result
				},
				body = cjson.encode( req )
			})
        else
			return cjson.decode( ar ), as, ah
        end
    end

    return cjson.decode( resp ), stat, head
end
----END----

--Проверка доступа пользователя
function help.auth( str )

	local templ = { 'et@get-net.ru', 'az@get-net.ru', 'nk@get-net.ru' }

	for i,v in pairs( templ ) do
		if v == str then
			return true
		end
	end

	return false
end
----END----

--Получение бинарника от СБИС и отправка файла в хранилище
function help.send_to_file_manager( link, name, pdf )
	local sid = db.query( 'SELECT * FROM session')[1].session
	
	local headers = {
		["content-type"] = "application/json-rpc;charset=utf-8",
		['Accept'] = '*/*, application/json-rpc',
		['X-SBISSessionID'] = sid
	}

	local resp,stat,head = http.simple({
		url = link,
		method = "GET",
		headers = headers,
	})

	if pdf then
		name = name .. '.pdf'
	else
		local templ = { '.xml', '.html', '.pdf' }

		local tmp, ext = pathx.splitext( name )

		if tablex.find( templ, ext ) then
			if ext == '.xml' or ext == '.html' then
				local cd = iconv.new('utf8','cp1251')
				local nstr, err = cd:iconv(resp)

				--print( nstr )

				if ext == '.xml' then
					resp = stringx.replace( nstr, 'encoding="windows-1251"', 'encoding="utf-8"' )
				end

				if ext == '.html' then
					resp = stringx.replace( nstr, 'charset=windows-1251', 'charset=utf-8' )
				end
			end
		else
			name = name .. '.pdf'
		end

	end

	local data = {
        uploaded_file = {
            filename = stringx.replace( name, '"', "'" ),
            data = resp
        }
    }

    local response = requests.post('https://file.gtn.ee/file/upload', {
		form = data,
		params = {
			test = 'kukuzapa sbisin'
		},
        headers = {
            ['Authorization'] = 'Bearer a0f4b317645f90af291a592eaca53eb69d988fa083e00fe98491738aaab554a8',
        }
	})
	
	--print( inspect (cjson.decode( response.text ) ) )

    return cjson.decode( response.text ).new_file.link
end
----END----

return help