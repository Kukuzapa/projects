local EP = {}

local helpers = require 'module.helpers'

EP.GET = function( self )

	if not helpers.auth( self.params.email ) then
		return { json = { error = 'Плохой пользователь' } }
	end

	local page = 0

	local req = {
		["jsonrpc"] = "2.0",
		["method"] = "СБИС.СписокДокументовПоСобытиям",
		["params"] = {
			["Фильтр"] = {
				["НашаОрганизация"] = {
					["СвЮЛ"] = {
						["ИНН"] = "5902174276",
						["КПП"] = "590201001"
					}
				},
				["Навигация"] = {
					["РазмерСтраницы"] = "200",
				}
			}
		},
		["id"] = 0
	}

	req["params"]["Фильтр"]["Навигация"]["Страница"] = tostring( page )

	if self.params.data_from then
		req['params']['Фильтр']['ДатаС'] = self.params.data_from
	end

	if self.params.data_to then
		req['params']['Фильтр']['ДатаПо'] = self.params.data_to
	end

	if self.params.type_reg then
		req['params']['Фильтр']['ТипРеестра'] = self.params.type_reg
	end

	if self.params.status then
		req['params']['Фильтр']['Состояние'] = self.params.status
	end

	if self.params.type_selected then
		req['params']['Фильтр']['ТипВложения'] = self.params.type_selected
	end

	local continue = 'Да'

	local fin = {}

	while continue == 'Да' do
		
		local resp, r_st, r_hd = helpers.wrapper( 'test', req )

		if r_st ~= 200 then
			return { json = { error = 'Проблема с получением данных' } }
		end

		for i,v in pairs( resp.result['Реестр'] ) do
			local tmp = {}

			tmp.date = v['Документ']['Дата']
			
			
			local partner = v['Документ']['Контрагент']['СвЮЛ'] or v['Документ']['Контрагент']['СвФЛ']
			local name = partner['Название'] or ''
			tmp.partner = partner['ИНН'] .. ' ' .. name
			
			tmp.name = v['Документ']['Название']
			tmp.type = v['Документ']['Тип']
			
			tmp.pdf_link = v['Документ']['СсылкаНаPDF']
			 
			--if v['Документ']['СсылкаНаPDF']:len() > 0 then
			--	tmp.pdf_link = '<a href="' .. v['Документ']['СсылкаНаPDF'] .. '">ПДФ</a>'
			--else
			--	tmp.pdf_link = 'Нет ссылки на документ'
			--end

			--tmp.sbis_link = v['Документ']['СсылкаДляНашаОрганизация']
			tmp.sbis_link = v['Документ']['СсылкаДляНашаОрганизация']

			--tmp.doc_id = v['Документ']['Идентификатор']
			tmp.doc_id = v['Документ']['Идентификатор']

			tmp.status = v['Состояние']

			tmp.date_time = v['ДатаВремя']

			tmp.attach = {}

			for q,w in pairs( v['Документ']['Вложение'] ) do
				table.insert( tmp.attach, w['Название'] )
			end
			
			
			table.insert( fin, tmp )
		end
		
		continue = resp.result['Навигация']['ЕстьЕще']

		page = page + 1

		req["params"]["Фильтр"]["Навигация"]["Страница"] = tostring( page )
	end
	
	
	
	return { json = fin }
	--return { json = { resp = resp, status = r_st, headers = r_hd } }
end


return EP