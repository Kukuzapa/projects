local helpers = require 'module.helpers'

local EP = {}

EP.GET = function( self )

	if not helpers.auth( self.params.email ) then
		return { json = { error = 'Плохой пользователь' } }
	end
	
	local req = {
		["jsonrpc"] = "2.0",
		["method"] = "СБИС.ПрочитатьДокумент",
		["params"] = {
			["Документ"] = {
				["Идентификатор"] = self.params.doc_id
			}
		},
		["id"] = 0
	}

	local fin = {}
	fin.files = {}

	local resp, r_st, r_hd = helpers.wrapper( 'test', req )

	for i,v in pairs( resp.result['Вложение'] ) do
		
		if v['Служебный'] == 'Нет' then
			
			local tmp = {}

			tmp.name = v['Название']
			tmp.pdf = v['СсылкаНаPDF']

			tmp.f_pdf = helpers.send_to_file_manager( tmp.pdf, tmp.name, 1 )

			tmp.file_name = v['Файл']['Имя']
			tmp.file_link = v['Файл']['Ссылка']

			tmp.f_file = helpers.send_to_file_manager( tmp.file_link, tmp.file_name )
		
			table.insert( fin.files, tmp )
		end
	end

	--table.insert( fin, { level = resp.result['Этап'][1]['Идентификатор'] } )
	
	if resp.result['Этап'] then
		fin.level = resp.result['Этап'][1]['Идентификатор']
	end

	return { json = fin }
end

return EP