local helpers = require 'module.helpers'

local EP = {}

EP.POST = function( self )

	--print( inspect( self.params ) )
	local req = {
		["jsonrpc"] = "2.0",
		["method"] = "СБИС.ПодготовитьДействие",
		["params"] = {
			["Документ"] = {
				["Идентификатор"] = self.params.doc,
				["Этап"] = {
					["Действие"] = {
						["Название"] = self.params.com
					},
					["Идентификатор"] = self.params.lev
				}
			}
		},
		["id"] = 0
	}

	if self.params.comment then
		req["params"]["Документ"]["Этап"]["Действие"]["Комментарий"] = self.params.comment
	end

	local resp, stat, head = helpers.wrapper( 'test', req )

	if stat ~= 200 then
		return { json = { error = 'Проблема с подготовкой документа - ' .. resp.error.details } }
	end

	local req = {
		["jsonrpc"] = "2.0",
		["method"] = "СБИС.ВыполнитьДействие",
		["params"] = {
			["Документ"] = {
				["Идентификатор"] = self.params.doc,
				["Этап"] = {
					["Действие"] = {{
						["Комментарий"] = "",
						["Название"] = self.params.com,
						["Сертификат"] = {{
							["Отпечаток"] = "97BE21EE2A18BE841205810BC6AA345A9E064A45"
						}}
					}},
					["Идентификатор"] = self.params.lev
				}
			}
		},
		["id"] = 0
	}

	if self.params.comment then
		req["params"]["Документ"]["Этап"]["Действие"][1]["Комментарий"] = self.params.comment
	end

	local resp, stat, head = helpers.wrapper( 'test', req )

	if stat ~= 200 then
		--print( inspect( req ) )
		--print( inspect( resp ) )
		return { json = { error = 'Проблема с выполнением команды - ' .. resp.error.details } }
	end

	return { json = { success = 'Операция ' .. self.params.com .. ' выполнена успешно.' } }
end

return EP