local helpers = require 'module.helpers'

local EP = {}

EP.POST = function( self )

	local fin = {}
	local level
	
	for i,v in pairs( self.params ) do

		local req = {
			["jsonrpc"] = "2.0",
			["method"] = "СБИС.ПрочитатьДокумент",
			["params"] = {
				["Документ"] = {
					["Идентификатор"] = i
				}
			},
			["id"] = 0
		}

		local resp, stat, head = helpers.wrapper( 'test', req )
		
		if stat ~= 200 then
			return { json = { error = 'Проблема с получением данных документа - ' .. resp.error.details } }
		end
		
		if resp.result['Этап'] then
			--fin.level = resp.result['Этап'][1]['Идентификатор']
			level = resp.result['Этап'][1]['Идентификатор']			
			--table.insert( fin, level )
		else
			--print( inspect( req ) )
			--print( inspect( resp ) )
			return { json = { error = 'Не смогли получить идентификатор этапа у документа с идентификатором ' .. i } }
		end

		local req = {
			["jsonrpc"] = "2.0",
			["method"] = "СБИС.ПодготовитьДействие",
			["params"] = {
				["Документ"] = {
					["Идентификатор"] = i,
					["Этап"] = {
						["Действие"] = {
							["Название"] = 'Утвердить'
						},
						["Идентификатор"] = level
					}
				}
			},
			["id"] = 0
		}

		local resp, stat, head = helpers.wrapper( 'test', req )
		
		if stat ~= 200 then
			return { json = { error = 'Проблема с подготовкой операции - ' .. resp.error.details } }
		end

		local req = {
			["jsonrpc"] = "2.0",
			["method"] = "СБИС.ВыполнитьДействие",
			["params"] = {
				["Документ"] = {
					["Идентификатор"] = i,
					["Этап"] = {
						["Действие"] = {{
							["Комментарий"] = "",
							["Название"] = 'Утвердить',
							["Сертификат"] = {{
								["Отпечаток"] = "97BE21EE2A18BE841205810BC6AA345A9E064A45"
							}}
						}},
						["Идентификатор"] = level
					}
				}
			},
			["id"] = 0
		}

		local resp, stat, head = helpers.wrapper( 'test', req )

		if stat ~= 200 then
			--print( inspect( req ) )
			--print( inspect( resp ) )
			return { json = { error = 'Проблема с выполнением команды - ' .. resp.error.details } }
		end
	end

	return { json = { success = 'Операция выполнена успешно.' } }
end

return EP