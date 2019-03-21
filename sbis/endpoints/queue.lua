local db = require("lapis.db")
local encoding = require("lapis.util.encoding")
local util = require("lapis.util")


local EP = {}

EP.POST = function(self)
	local params = {}

	params.file = {}

	for i,v in pairs( self.params ) do
		if type( v ) =='table' then
			local tmp = {}

			tmp.filename = v.filename
			tmp.content  = encoding.encode_base64( v.content )

			table.insert( params.file, tmp )
		else
			params[i] = v
		end
	end

	db.query( 'INSERT INTO requests (request,status,doc_id,date_req) VALUES (?,?,?,NOW())', util.to_json( params ), 'process', params.id )

	return { json = { success = 'Добавили в очередь отправки' } }
end

return EP