--Конфигурация
local conf = require 'postgres_conf'
--Работа с json
local cjson = require "cjson"
--Сторки
local stringx = require 'pl.stringx'
--Шаблоны
local templ = require 'templates'

--local http  = require "resty.http"
--local httpc = http.new()

local request = require 'request'

local inspect = require 'inspect'

local utf8 = require 'lua-utf8'

local requests = require('requests')

local pgmoon = require 'pgmoon'
local pg = pgmoon.new( conf.postgres )

local success, err = pg:connect()

if err then
	print( os.date('%c',os.time()) .. ': Ошибка соеденения с БД - ' .. err )
    return
end

local fid = '24e089b91adce598c0ea3f5c8057dd9c0a54e937b9198c2bd16df9deea7b44f0'

local mid = 'a0f4b317645f90af291a592eaca53eb69d988fa083e00fe98491738aaab554a8'

--ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
--Функция отправки файлов в файловый менеджер
local function file_manager( bin, name, ct, link )
	--СДЕЛАТЬ поправить глюк с двоными ковычками
    local data = {
        uploaded_file = {
            filename = stringx.replace( name, '"', "'" ),
            content_type = ct,
            data = bin
        }
    }

    local response = requests.post('https://file.gtn.ee/file/upload', {
        form = data,
        headers = {
            ['Authorization'] = 'Bearer a0f4b317645f90af291a592eaca53eb69d988fa083e00fe98491738aaab554a8',
        }
    })

    return cjson.decode( response.text ).new_file.link
end

--Проверка необходимости создания почтового уведомления
local function check_mailer( test )
	local templ = { 'счет', 'счёт', 'фактура', 'счфктр', 'упдсчфдоп', 'эдосч', 'эдосчет' }

	if not test then
		return false
	end

	for i,v in pairs( templ ) do
		if utf8.find( utf8.lower( test ), v ) then
			return true
		end
	end

	return false
end

--Обертка для обмена со СБИС
local function wrapper( command, date_from, action_id )
    --Берем сессия ид
	local sid = pg:query( 'SELECT session FROM session' )[1].session
	
	print( sid )

    local res, req

    if command == 'history' then
    
        req = templ[command]( conf.getnet.inn, conf.getnet.kpp, date_from, action_id )

        res = request.send( sid, req )
    else
        res = request.binary( sid, date_from, action_id )
    end

    if res.status == 401 then
        local areq = templ.auth( conf.getnet.login, conf.getnet.pass )

        local auth = request.auth( sid, areq )

		if auth.status == 200 then
			pg:query( 'UPDATE session SET session = ' .. pg:escape_literal( auth.body.result ) .. ',updated = NOW() WHERE session = ' .. pg:escape_literal( sid ) )
			if command == 'history' then
				
				--print( inspect( req ) )

                res = request.send( auth.body.result, req )
            else
                res = request.binary( sid, date_from, action_id )
            end
            print( os.date('%c',os.time()) .. ': Запрос нового идентификатора сессии - успешно' )
        else
            print( os.date('%c',os.time()) .. ': Запрос нового идентификатора сессии - фиаско' )
        end
    end

    return res.body
end

--Формирование красивой переменной для postgress pgmoon
local function test( tst, date )
	if tst then
		if type( tst ) == 'string' and tst:len() == 0 then
			return 'NULL'
		end
		if date then
			local split = stringx.split( tst, '.' )
			return pg:escape_literal( split[3] .. '-' .. split[2] .. '-' .. split[1] )
		end
		return pg:escape_literal( tst )
	else
		return 'NULL'
	end
end
--КОНЕЦ ВСПОМОГАТЕЛЬНЫМ ФУНКЦИЯМ



--Вот эти вещи должны браться из базы. Если точнее, то номер события
local action_id = pg:query( 'SELECT * FROM last_input_id ORDER BY id DESC LIMIT 1' )
--print( inspect( action_id ) )
if #action_id == 0 then
    action_id = ''
else
    action_id = action_id[1].last_id
end

--action_id = ''

local date_from = '30.10.2018 00.00.00'
local fin = {}

local count = 0

local continue = 'Да'

--Начали обработку входящих документов
while continue == 'Да' do
    local res = wrapper( 'history', date_from, action_id )

    --print( inspect( res.result ) )

    if res.result then    
        for _,doc in pairs( res.result["Документ"] ) do
            if doc["Направление"] == 'Входящий' then
                for _,action in pairs( doc["Событие"] ) do
                    if action["Название"] == "Получение" then
                        local tmp = {}
                        tmp.number = doc["Номер"]
                        tmp.name = doc["Название"]
                        tmp.date = doc["Дата"]
                        tmp.type = doc["Тип"]
                        tmp.partner = {}
                        tmp.partner.type = doc["Контрагент"]["СвЮЛ"] and "СвЮЛ" or "СвФЛ"
                        tmp.partner.name = doc["Контрагент"][tmp.partner.type]["Название"]
                        tmp.partner.inn = doc["Контрагент"][tmp.partner.type]["ИНН"]
                        tmp.partner.kpp = doc["Контрагент"][tmp.partner.type]["КПП"]
						tmp.attach = {}
						--tmp.mail = {}
                        for _,z in pairs( action["Вложение"] ) do
                            if z["Служебный"] == "Нет" then
                                local a_tmp = {}
                                a_tmp.pdf = z["СсылкаНаPDF"]
                                a_tmp.number = z["Номер"]

                                if stringx.endswith( z["Название"], 'pdf' ) then
                                    a_tmp.name = z["Название"]
                                else
                                    a_tmp.name = z["Название"] .. '.pdf'
                                end

                                a_tmp.type = z["Тип"]
                                a_tmp.date = z["Дата"]
                                a_tmp.file = {}
                                a_tmp.file.name = z["Файл"]["Имя"]
                                a_tmp.file.link = z["Файл"]["Ссылка"]
                                table.insert( tmp.attach, a_tmp )
                            end
                        end
                        table.insert( fin, tmp )
                    end
                end
            end
            --Здесь запоминаем событие последнее в массиве событий данного документа
            action_id = doc["Событие"][#doc["Событие"]]["Идентификатор"]
			
			local sql = 'INSERT INTO last_input_id (last_id) VALUES (' .. pg:escape_literal( action_id ) .. ')'
			
			local ins, err = pg:query( sql )

			if not ins then
                print( os.date('%c',os.time()) .. ': Проблема с записью идентификатора последнего обработанного события (' .. sql .. ') ' .. err )
            end
        end
    else
        print( os.date('%c',os.time()) .. ': Проблема с запросом входящего сообщения' )
        print( inspect( res ) )
        return
    end
    --Получаем признак наличия следующей страницы
    continue = res.result["Навигация"]["ЕстьЕще"]
end

--print( inspect( fin ) )

--Мы получили массив документов, пришло время получить бинарники файлов
--Пройдем по всем документам
for j,doc in pairs( fin ) do
    --По всем аттачам
    for i,attach in pairs( doc.attach ) do
        --Проверим имя файла в аттаче. Если совпадает с названием пдф представления не качаем
        if attach.name ~= attach.file.name then
            local res_d = wrapper( 'binary', attach.file.link, 'xml' )

            if res_d.error then
                print( os.date('%c',os.time()) .. ': Проблема с получением бинарника' )
                print( inspect( res_d ) )
                return
            else
                fin[j].attach[i].file.link = file_manager( res_d, attach.file.name, 'text/xml' )
            end
        else
            fin[j].attach[i].file = nil
        end

        local res = wrapper( 'binary', attach.pdf )

        if res.error then
            print( os.date('%c',os.time()) .. ': Проблема с получением бинарника' )
            print( inspect( res ) )
            return
        else
            fin[j].attach[i].pdf = file_manager( res, attach.name, 'application/pdf' )
        end
    end
end

--print( inspect( fin ) )

--И вот мы загрузили все файло в файловый менеджер и сохранили ссылки. Пришло время записать в базу и отправить письма
local inputs = 0
local attachs = 0
local mails = 0

for i,v in pairs( fin ) do
	
	local mail = {}

	local sql = string.format( 'INSERT INTO input (type,date,name,number,p_inn,p_kpp,p_name) VALUES (%s,%s,%s,%s,%s,%s,%s) RETURNING id',
		test( v.type ), test( v.date, 'date' ), test( v.name ), test( v.number ), test( v.partner.inn ), test( v.partner.kpp ), test( v.partner.name ) )

	local ins, err = pg:query( sql )
	local input_id

    if not ins then
        print( os.date('%c',os.time()) .. ': Не смогли записать информацию во входящие - ' .. sql .. ' : ' .. err )
	else
		input_id = ins[1].id
		inputs = inputs + 1
	end

    for j,u in pairs( v.attach ) do

		--print( string.format( 'INSERT INTO attachments (in_id,link,name,number,type) VALUES (%s,%s,%s,%s,%s)',
		--	test( input_id ), test( u.pdf ), test( u.name ), test( u.number ), test( u.type ) ) )

		local sql = string.format( 'INSERT INTO attachments (in_id,link,name,number,type) VALUES (%s,%s,%s,%s,%s)',
			test( input_id ), test( u.pdf ), test( u.name ), test( u.number ), test( u.type ) )

		local ins_att, err = pg:query( sql )
    
		if not ins_att then
			print( os.date('%c',os.time()) .. ': Не смогли записать информацию в аттач - ' .. sql .. ' : ' .. err )
		else
			attachs = attachs + 1
		end

		if check_mailer( u.name ) or check_mailer( u.type ) then
			table.insert( mail, { name = u.name, file = u.pdf } )
		end
			
		if u.file then
			
			--print( string.format( 'INSERT INTO attachments (in_id,link,name,number,type) VALUES (%s,%s,%s,%s,%s)',
			--	test( input_id ), test( u.file.link ), test( u.file.name ), test( u.number ), test( u.type ) ) )

			local sql = string.format( 'INSERT INTO attachments (in_id,link,name,number,type) VALUES (%s,%s,%s,%s,%s)',
				test( input_id ), test( u.pdf ), test( u.name ), test( u.number ), test( u.type ) )

			local ins_att, err = pg:query( sql )
    
			if not ins_att then
				print( os.date('%c',os.time()) .. ': Не смогли записать информацию в аттач 2 - ' .. sql .. ' : ' .. err )
			else
				attachs = attachs + 1
			end
		end

		if #mail > 0 then

			for z,x in pairs( mail ) do

				local binary = requests.get( x.file )

				html = '<p>В СБИС пришел счет.</p>'

				html = html .. string.format( '<p><a href="%s">%s</a></p>', x.file, x.name )

				local data = {
					uid_provider = "ab17d67c-d11f-11e8-ba29-efa683cf4956",
					send_to = conf.getnet.mail,
					subject = "Входящее сообщение от СБИС",
					html = html,
					attachment = {
						filename = stringx.replace( x.name, '"', "'" ),
						content_type = 'application/pdf',
						data = binary.text
					}
				}
				
				local response = requests.post('https://mailer.gtn.ee/api/v1.0/mail/attachment', {
					form = data,
					headers = {
						['Authorization'] = 'Bearer a0f4b317645f90af291a592eaca53eb69d988fa083e00fe98491738aaab554a8',
					}
				})
				mails = mails + 1
			end
		end
    end
end

print( os.date('%c',os.time()) .. ': событий обработано - ' .. inputs .. ', вложений - ' .. attachs .. ', писем отправлено - ' .. mails )
