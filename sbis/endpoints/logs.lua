local db = require("lapis.db")

local EP = {}

EP.GET = function(self)

	local params = self.params
	
	local sql = 'SELECT * FROM requests'

	local where = {}
	local w_str = ' '
	local log
	local ids = {}
	
	if params.doc_id then
		table.insert( where, ' doc_id = ' .. db.escape_literal( params.doc_id ) .. ' ' )
	end

	if params.status then
		table.insert( where, ' status = ' .. db.escape_literal( params.status ) .. ' ' )
	end

	if params.b_date then
		table.insert( where, ' date_req >= ' .. db.escape_literal( params.b_date .. ' 00:00:00' ) .. ' ' )
	end

	if params.e_date then
		table.insert( where, ' date_req <= ' .. db.escape_literal( params.e_date .. ' 23:59:59' ) .. ' ' )
	end

	for i,v in pairs( where ) do
		if i == 1 then
			w_str = w_str .. 'WHERE' .. v
		else
			w_str = w_str .. 'AND' .. v
		end
	end

	sql = sql .. w_str

	local sel, err = db.query( sql )

	if params.log then

		for i,v in pairs( sel ) do
			table.insert( ids, db.escape_literal( v.doc_id ) )
		end

		log = db.query( 'SELECT * FROM log WHERE doc_id IN (' .. table.concat( ids, ',' ) .. ')' )

		for i,v in pairs( sel ) do

			sel[i].log = {}

			for j,u in pairs( log ) do
				if v.doc_id == u.doc_id then
					table.insert( sel[i].log, log[j] )
				end
			end
		end
	end

	return { json = sel }
end

return EP