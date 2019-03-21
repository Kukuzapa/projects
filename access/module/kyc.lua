local kyc = {}

local db = require("lapis.db")
local stringx = require 'pl.stringx'
--local tablex = require 'pl.tablex'
local http = require("lapis.nginx.http")
local util = require("lapis.util")

-- Отладка
local inspect = require( 'inspect' )

function kyc.auth_check( req )

    --Получили хидер
    local token = req.headers.authorization

    --Снесли заведомо гнилые сессии
    db.query( 'DELETE FROM sessions WHERE tscreate + INTERVAL 1 DAY < NOW()' )

    --Если хидера нет, не успех
    if not token then
        return false
    end

    local uid

    --Получили токен
    local token = stringx.split( token, ' ' )[2]

    if not token then
        return false
    end

    --Проверим есть ли сессия с данным токеном и временем проверки меньше 15 минут
    --local res = db.query( [[SELECT * FROM sessions WHERE access = ?
	--    AND ( (UNIX_TIMESTAMP(tscreate)+expires_in)>UNIX_TIMESTAMP() OR expires_in = -1 )
    --    AND ( (UNIX_TIMESTAMP(tsupdate)+900)>UNIX_TIMESTAMP() )]], token )

    local res = db.query( [[SELECT * FROM sessions WHERE access = ?
        AND ( (tscreate + INTERVAL 1 DAY) > NOW() OR expires_in = -1 )
        AND ( (tsupdate + INTERVAL 15 MINUTE) > NOW() )]], token )
    --Если нет, то  
    if #res == 0 then

        --Сделаем запрос в кик для информации о пользователе
        local body, status_code, headers = http.simple({
            url = "https://id.gtn.ee/oauth/introspect",
            method = "POST",
            headers = {
                ["content-type"] = "application/x-www-form-urlencoded",
                ["Authorization"] = "Bearer " .. token  
            },
            body = {
                token = token
            }
        })

        local client = util.from_json(body)

        --Если запрос успешен и учетка пользователя в кике активна, то
        if client and client.active then

            --Взяли уид клиента из кика
            uid = client.client_id
            
            --Проверим наличие пользователя в БД по уид
            local check_user = db.query( 'SELECT * FROM users WHERE userid = ?', client.client_id )

            --Если нет, то надо добавить в БД
            if #check_user == 0 then
                --Получим кол-во пользователей из БД
                local all_users = db.query( 'SELECT * FROM users' )

                --Если пока ноль, то пишем его как админа, если нет, то как юзера
                --if #all_users == 0 then
                --    db.query( 'INSERT INTO users (userid,name,email,isadmin) VALUES (?,?,?,1)',
                --        client.client_id, client.fullname, client.email )
                --else
                    db.query( 'INSERT INTO users (userid,user,email) VALUES (?,?,?)',
                        client.client_id, client.fullname, client.email )

                    
                    --local user_id = db.query( 'SELECT id FROM users WHERE userid = ?', client.client_id )[1].id
                    ----END----
            
                    --Даем новому пользователю права на проход корневого узла
                    --local node = db.query( 'SELECT node FROM nodes WHERE pid IS NULL')[1].node
            
                    db.query( [[INSERT INTO acl_grants_users (user,node,grnt) VALUES (
                        (SELECT id FROM users WHERE userid = ?),
                        (SELECT id FROM nodes WHERE pid IS NULL),
                        (SELECT id FROM grants WHERE grnt = 'pass')
                    )]], client.client_id )
                    
                    --helpers.set_grants( 'users', user_id, node, 'pass' )
                --end
            end

            --Проверяем наличие какой-либо записи в БД по данному токену
            local session = db.query( 'SELECT * FROM sessions WHERE access = ?', token )

            --Если есть, то ставим время проверки на сейчас
            if #session > 0 then
                db.query( 'UPDATE sessions SET tsupdate = NOW() WHERE access = ?', token )
            --Иначе
            else
                local expires_in = client.exp-client.iat

                if client.exp == -1 then
                    expires_in = -1
                end

                --Добавляем в сессии новую запись
                db.query( [[INSERT INTO sessions (access,tscreate,tsupdate,expires_in,client)
                    VALUES (?,FROM_UNIXTIME(?),NOW(),?,?)]], token, client.iat, expires_in, client.client_id )
            end

        --Запрос не успешен или учетка не активна.
        else
            --Проверяем запись в сессиях и сносим ее
            local session = db.query( 'SELECT * FROM sessions WHERE access = ?', token )

            if #session > 0 then
                db.query( 'DELETE FROM sessions WHERE access = ?', token )
            end

            return false
        end
    else
        --Сессия была свежая, взяли уид из таблицы сессий
        uid = res[1].client
    end

    --Проверка прав на действие
    --Для начала прав на операции админов
    --Если в пути есть админ
    --if stringx.lfind ( req.parsed_url.path, '/admin/' ) then
    --    local sel = db.query( 'SELECT * FROM users WHERE userid = ? AND isadmin = 1', uid )

    --    if #sel == 0 then
    --        return false
    --    end
    --Запрос пользователя
    --else
        --Есть только один запрос в котором нет userid
    --    if req.parsed_url.path ~= '/vm/user/get' then
    --        local sel = db.query( 'SELECT * FROM users WHERE id = ?', req.params_get.userid )

    --        if sel[1].userid ~= uid then
    --            return false
    --        end
    --    end
    --end

    return true
end

return kyc