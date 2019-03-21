local date = require 'date'

local templates = {}
    --Аутотентификация
    function templates.auth( login, pass )
        return {
            ["jsonrpc"] = "2.0",
            ["method"]  = "СБИС.Аутентифицировать",
            ["params"]  = {
                ["Логин"]  = login,
                ["Пароль"] = pass
            },
            ["id"] = 0
        }
    end

    --Контрагент
    function templates.partner( body )
        local member = {} 
		local type = 'СвЮЛ'

		if body.inn:len() == 12 then
			type = 'СвФЛ'
			member[type] = { ["ИНН"] = body.inn }
		else
			member[type] = { ["ИНН"] = body.inn, ["КПП"] = body.kpp }
		end

		return {
			jsonrpc = "2.0",
			method = "СБИС.ИнформацияОКонтрагенте",
			params = { ["Участник"] = member },
			id = 0
		}
    end

    --Подготовка
    function templates.prepare( body, inn, kpp )

        local partner = {}

        local p_type = 'СвЮЛ'

		if body.inn:len() == 12 then
			p_type = 'СвФЛ'
			partner[p_type] = { ["ИНН"] = body.inn }
		else
			partner[p_type] = { ["ИНН"] = body.inn, ["КПП"] = body.kpp }
		end
        
        local doc_type = 'ДокОтгрИсх'
		local text = 'Акт об оказании услуг'

		if body.type == 'invoice' then
			doc_type = 'СчетИсх'
			text = 'Счет на оплату'
		end

		local dte = date():fmt('%d.%m.%Y')

		local files = {}
		
		for i,v in pairs( body.file ) do
			local tmp   = {
				["Файл"] = {
					["ДвоичныеДанные"] = v.content,
					["Имя"] = v.filename
				}
			}
			table.insert( files, tmp )
		end
		
		return {
			jsonrpc = "2.0",
			method = "СБИС.ЗаписатьДокумент",
			params = {
				["Документ"] = {
					["Вложение"] = files,
					["Дата"] = dte,
					["Идентификатор"] = body.id,
					["Контрагент"] = partner,
					["НашаОрганизация"] = {
						["СвЮЛ"] = {
							["ИНН"] = inn,
							["КПП"] = kpp
						}
					},
					["Примечание"] = text,
					["Тип"] = doc_type
				}
			},
			id = 0
		}
    end

    --Отправка документа
    function templates.send( body )
        return {
			["jsonrpc"] = "2.0",
			["method"] = "СБИС.ВыполнитьДействие",
			["params"] = {
				["Документ"] = {
					["Идентификатор"] = body.id,
					["Этап"] = {{
						["Действие"] = {{
							["Название"] = "Отправить",
						}},
						["Название"] = "Отправка",
						["Служебный"] = "Нет"
					}}
				}
			},
			["id"] = 0
		}
	end
	
	--Запрос истории
	function templates.history( inn, kpp, date_from, aid )

		local req = {
			["jsonrpc"] = "2.0",
			["method"] = "СБИС.СписокИзменений",
			["params"] = {
				["Фильтр"] = {
					--["ИдентификаторСобытия"] = "",
					--["ДатаВремяС"] = "01.03.2018 00.00.00",
					["НашаОрганизация"] = {
						["СвЮЛ"] = {
							["ИНН"] = inn,
							["КПП"] = kpp
						}
					},
					["ПолныйСертификатЭП"] = "Нет",
				}
			},
			["id"] = 0
		}
		
		if aid then
			req["params"]["Фильтр"]["ИдентификаторСобытия"] = aid
		end

		if date_from then
			req["params"]["Фильтр"]["ДатаВремяС"] = date_from
		end

		return req
	end

	--Формируем массив вложений
	function templates.inbox( tbl )
		
	end

return templates