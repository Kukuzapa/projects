-- ТЦИ АПИ 2

-- Отладка
local inspect = require( 'inspect' )

local config = require("lapis.config").get()
local db     = require("lapis.db")
local util   = require("lapis.util")

local idn = require 'module.punycode.idn'

local domain  = require 'module.domain'
local format  = require 'module.format'

local lfs     = require 'lfs'
local zlib    = require 'zlib'

local stringx = require 'pl.stringx'

local idn    = require 'module.punycode.idn'


local function text_reg( val )
	if val == 1 then
		return 'RU'
	else
		return 'RF'
	end
end

frontControllerProgged = {}
function frontControllerProgged:new( params )
	local private = {}
	local public = {}

	-- Веб-интерфейс
	-- {}
	function frontControllerProgged:get_base( params )

		local sel
		local fin = {}
		
		if params.obj == 'dom' then
			sel = db.query( 'SELECT * FROM domains WHERE name LIKE "%' .. params.query .. '%"' )

			for i=1,20 do
				if sel[i] then
					local tmp = {}
					tmp.value = sel[i].name
					tmp.data = sel[i]
					table.insert(fin,tmp)
				end
			end
		end

		if params.obj == 'con' then
			if params.reg then
				local rr
				if params.reg == 'ru' then
					rr = '1'
				else
					rr = '2'
				end

				sel = db.query( [[SELECT * FROM contacts 
					WHERE id_registrars = "]]..rr..[[" AND (intPostalInfo_name LIKE "%]]..params.query..[[%" || intPostalInfo_org LIKE "%]]..params.query..[[%")]] )

				if #sel == 0 then
					sel = db.query( [[SELECT * FROM contacts 
						WHERE id_registrars = "]]..rr..[[" AND (locPostalInfo_name LIKE "%]]..params.query..[[%" || locPostalInfo_org LIKE "%]]..params.query..[[%")]] )
				end

				if #sel == 0 then
					sel = db.query( 'SELECT * FROM contacts WHERE id_registrars = "'..rr..'" AND taxpayerNumbers LIKE "%'..params.query..'%"' )
				end

				for i=1,20 do
					if sel[i] then
						local tmp = {}

						local unique
						if sel[i].taxpayerNumbers and type( sel[i].taxpayerNumbers ) ~= 'userdata' then
							unique = sel[i].taxpayerNumbers
						else 
							if sel[i].passport and type( sel[i].passport ) ~= 'userdata' then
								unique = sel[i].passport
							else
								unique = 'NU' .. sel[i].id
							end
						end
						
						if type( sel[i].locPostalInfo_name ) == 'userdata' then
							tmp.value = sel[i].locPostalInfo_org .. ', ' .. unique
						else
							tmp.value = sel[i].locPostalInfo_name .. ', ' .. unique
						end

						tmp.data = sel[i]
						table.insert(fin,tmp)
					end
				end
			else
				sel = db.query( [[SELECT * FROM contacts 
					WHERE intPostalInfo_name LIKE "%]]..params.query..[[%" || intPostalInfo_org LIKE "%]]..params.query..[[%"]] )

				if #sel == 0 then
					sel = db.query( [[SELECT * FROM contacts 
						WHERE locPostalInfo_name LIKE "%]]..params.query..[[%" || locPostalInfo_org LIKE "%]]..params.query..[[%"]] )
				end

				if #sel == 0 then
					sel = db.query( 'SELECT * FROM contacts WHERE taxpayerNumbers LIKE "%' .. params.query .. '%"' )
				end

				for i=1,20 do
					if sel[i] then
						local tmp = {}

						local unique
						if sel[i].taxpayerNumbers and type( sel[i].taxpayerNumbers ) ~= 'userdata' then
							unique = sel[i].taxpayerNumbers
						else 
							if sel[i].passport and type( sel[i].passport ) ~= 'userdata' then
								unique = sel[i].passport
							else
								unique = 'NU' .. sel[i].id
							end
						end

						if type( sel[i].locPostalInfo_name ) == 'userdata' then
							tmp.value = sel[i].locPostalInfo_org .. ' - ' .. text_reg( sel[i].id_registrars ) .. ', ' .. unique
						else
							tmp.value = sel[i].locPostalInfo_name .. ' - ' .. text_reg( sel[i].id_registrars ) .. ', ' .. unique
						end

						tmp.data = sel[i]
						table.insert(fin,tmp)
					end
				end
			end				
		end
		
		return { json = { suggestions = fin } }
	end

	-- История
	-- { "count", "type", "clid" }
	function frontControllerProgged:get_history( params )
		
		local from = params.per_from .. ' 00:00:00'
		local to   = params.per_to .. ' 23:59:59'

		local count = db.query( 'SELECT count(*) FROM queueClient WHERE date > "' .. from .. '" AND date < "' .. to .. '"' )[1]['count(*)']
		
		local sel = db.query( 'SELECT * FROM queueClient WHERE date > "' .. from .. '" AND date < "' .. to .. '" ORDER BY id DESC LIMIT ' .. params.count .. ' OFFSET ' .. params.clid )

		return { json = { count = count, list = sel } }
	end

	-- Сохраненные сообщения от ТЦИ
	-- { "tld" }
	function frontControllerProgged:get_poll( params )

		local tld

		if params.tld == 'ru' then
			tld = '1'
		else
			tld = '2'
		end

		local count = db.query( 'SELECT count(*) FROM polls WHERE id_registrars = ?', tld )[1]['count(*)']

		local sel = db.query( 'SELECT * FROM polls WHERE id_registrars = ? ORDER BY msg_date DESC LIMIT 10 OFFSET ' .. (params.page - 1)*10, tld )


		return { json = { count=count, list = sel } }
	end

	-- list of domain
	-- { "tld" }
	function frontControllerProgged:get_list( params )
		
		local count = db.query( [[SELECT count(*) FROM domains
									INNER JOIN contacts ON domains.id_contacts = contacts.id
									WHERE domains.name LIKE "%]] .. params.domain .. [[%"
									ORDER BY domains.]] .. params.column .. [[ ]] .. params.dir )[1]['count(*)']

		local offset = (params.page - 1)*10

		local fin = db.query( [[SELECT domains.name,contacts.locPostalInfo_name,locPostalInfo_org,domains.status,domains.exdate,domains.upddate,domains.nss FROM domains
									INNER JOIN contacts ON domains.id_contacts = contacts.id
									WHERE domains.name LIKE "%]] .. params.domain .. [[%"
									ORDER BY domains.]] .. params.column .. [[ ]] .. params.dir .. [[ LIMIT 10 OFFSET ]] .. (params.page - 1)*10 )
		
		return { json = { count=count, list = fin } }
	end

	-- list of domain
	-- { "tld" }
	function frontControllerProgged:get_sync( params )
		
		local body = {}

		for i,v in pairs( config[params.tld] ) do
			body[i] = v
		end

 		--ngx.say(params.domain)

 		local dom = idn.decode( params.domain:lower() )

 		ngx.say( dom )

 		body.name = dom

 		body.clTRID = format.QC_insert( 'domain', 'copy', util.to_json( body ) )

		local is_success, fin = pcall( domain.copy, body )

		if not is_success then fin = format.err( fin ) end

		fin.clTRID = body.clTRID

		db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )

		return { json = fin }
	end

	-- GETDATA
	function frontControllerProgged:get_getdata( params )
		-- код писать тут
		local test
		local file_name

		for file in lfs.dir( lfs.currentdir() .. '/getdata/files/' .. params.tld .. '/' ) do
        	--table.insert( current_file_list, file )
        	if string.find( file, params.type ) then
        		file_name = file
        	end
    	end

		if not file_name then
    		return { json = { error = true, message = 'Недопустимый тип данных.' } }
    	end

		local file, err = io.open( lfs.currentdir() .. '/getdata/files/' .. params.tld .. '/' .. file_name )

		if err then
			return { json = { error = true, message = 'Не вышло открыть файл. Попробуйте позже. На неделе.' } }
		end

		local compressed_data = file:read( '*a' )

		local decompressed_data = zlib.decompress( compressed_data, 31 )

		if params.type == 'DomainDistrib' then
			
			local domain_distrib = stringx.splitlines( decompressed_data )

			local fin = {}

			for _,line in pairs( domain_distrib ) do
				local split = stringx.split( line )

				table.insert( fin, { reg = split[1], count = split[2] } )
			end

			return { json = fin }
		end

		if params.type == 'DelList' then

			local del_list = stringx.splitlines( decompressed_data )

			for i,v in pairs( del_list ) do
				del_list[i] = idn.decode( v )
			end

			return { json = { count = #del_list, list = del_list } }
		end

		if params.type == 'DelReport' then

			local del_report = stringx.splitlines( decompressed_data )

			local fin = {}

			for _,line in pairs( del_report ) do
				local split = stringx.split( line )

				table.insert( fin, { date = split[1], time = split[2], domain = idn.decode( split[3] ), operation = split[4], reg = split[5] } )
			end

			return { json = { count = #del_report, list = fin } }
		end

		return { json = { error = true, message = 'Указанный тип данных не обслуживается.' } }

		--return { json = { params = inspect( params ), test = test, currentdir = lfs.currentdir(), file_name = file_name } }
	end

	setmetatable( public, self )
	self.__index = self
	return public

end
