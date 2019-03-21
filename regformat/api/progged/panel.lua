-- ТЦИ АПИ 2

-- Отладка
local inspect = require( 'inspect' )

local config = require("lapis.config").get()
local util   = require("lapis.util")
local db     = require("lapis.db")

local pathx   = require 'pl.path'
local stringx = require 'pl.stringx'

local domain  = require 'module.domain'
local format  = require 'module.format'



local TLD = { ['рф'] = 'rf', ['ru'] = 'ru' }

local function error_dict( tbl, dmn )
	local dict = {
		['2005'] = {
			["error_code"] = "PARAMETER_INCORRECT",
        	["error_text"] = tbl.reason,
        	["result"]     = "error"
		},
		['2303'] = {
			["error_code"] = "DOMAIN_NOT_FOUND",
        	["error_text"] = "Domain " .. dmn .. " not found or not owned by You",
        	["result"]     = "error"
		},
		['4224'] = {
			["error_code"] = "SERVICE_UNAVAILABLE",
        	["error_text"] = 'TCI API v 2.0 is temporarily unavailable',
        	["result"]     = "error"
		}
	}

	if dict[tbl.code] then
		return dict[tbl.code]
	else
		return tbl
	end
end

panelControllerProgged = {}
function panelControllerProgged:new( params )
	local private = {}
	local public = {}

	-- panel domain create
	-- { "username", "password" }
	function panelControllerProgged:post_panel_domain_create( params )
		-- код писать тут
		return {
			json = {
				success = true,
				error = false,
				message = 'NYI; DEBUG: ' .. inspect( params )
			}
		}
	end

	-- panel domain check
	-- { "domain_name", "input_format", "input_data", "username", "password" }
	function panelControllerProgged:get_panel_domain_check( params )

		local domain_check_list = {}

		local response_list = {}

		if params.domain_name then
			table.insert( domain_check_list, { key = 'dname', domain = params.domain_name } )
		else
			local tmp = util.from_json( params.input_data )

			for _,v in pairs( tmp.domains ) do
				for k,u in pairs( v ) do
					table.insert( domain_check_list, { key = k, domain = u } )
				end
			end
		end

		for i,v in pairs( domain_check_list ) do
			local body = {}

			local tld = string.lower( pathx.extension( v.domain ) ):sub( 2 )

			if config[ TLD[ tld ] ] then
				

				for i,v in pairs( config[ TLD[ tld ] ] ) do
					body[i] = v
				end

				body.name = v.domain

				body.clTRID = format.QC_insert( 'domain', 'check', util.to_json( body ) )

				local is_success, fin = pcall( domain.check, body )

				if not is_success then fin = format.err( fin ) end

				fin.clTRID = body.clTRID

				db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )

					
				if fin.result[1].code == '1000' then
					local dict = {
						['0'] = {
							[v.key]        = v.domain,
            				["error_code"] = "DOMAIN_ALREADY_EXISTS",
            				["error_text"] = "Domain already exists, use whois service",
            				["result"]     = "error"
						},
						['1'] = {
							[v.key]    = v.domain,
							["result"] = "Available"
						}
					}

					table.insert( response_list, dict[ fin.check[ v.domain ] ] )
				else
					table.insert( response_list, error_dict( fin.result[1], v.domain ) )
				end
			else
				local tmp = {
					[v.key]        = v.domain,
            		["error_code"] = "INVALID_DOMAIN_NAME_FORMAT",
            		["error_text"] = v.domain .. " is invalid or unsupported zone",
            		["result"]     = "error"
				}

				table.insert( response_list, tmp )
			end
		end

		return { json = { answer = { domains = response_list }, result = 'success' } }
	end

    -- panel domain get transfer status
	-- { "username", "password", "input_format", "input_data", "output_content_type" }
	function panelControllerProgged:get_panel_domain_get_transfer_status( params )
		-- код писать тут
		--local domain_list = {}

		local response_list = {}

		--util.from_json( params.input_data )
		local input_data = util.from_json( params.input_data )

		--table.insert( input_data.domains, { dname = '0000.ru' } )

		for i,v in pairs( input_data.domains ) do

			--ngx.say( v.dname )
			local body = {}

			local tld = string.lower( pathx.extension( v.dname ) ):sub( 2 )

			

			if config[ TLD[ tld ] ] then
				
				for i,v in pairs( config[ TLD[ tld ] ] ) do
					body[i] = v
				end

				body.name = v.dname


				body.clTRID = format.QC_insert( 'domain', 'get', util.to_json( body ) )

				local is_success, fin = pcall( domain.get, body )

				if not is_success then fin = format.err( fin ) end

				fin.clTRID = body.clTRID

				db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )



				if fin.result[1].code == '1000' then

					local dict = {
						['clientTransferProhibited'] = 'clientTransferProhibited',
						['changeProhibited'] = 'transferProhibited',
						['serverTransferProhibited'] = 'transferProhibited',
						['pendingTransfer'] = 'pendingTransfer'
					}

					local tmp = 'notAvailable'

					for i,v in pairs( fin.domain.status ) do
						if dict[v] then
							tmp = dict[v]
						end
					end
					 

					table.insert( response_list, { dname = v.dname, status = tmp } )
				else
					table.insert( response_list, error_dict( fin.result[1], v.dname ) )
				end

				--table.insert( response_list, fin )

			else
				local tmp = {
					["dname"]        = v.dname,
            		["error_code"] = "INVALID_DOMAIN_NAME_FORMAT",
            		["error_text"] = v.dname .. " is invalid or unsupported zone",
            		["result"]     = "error"
				}

				table.insert( response_list, tmp )
			end


		end

		return { json = { answer = { domains = response_list }, result = 'success' } }
	end

	-- panel domain set new authInfo
	-- { "username", "password", "authinfo", "dname", "output_content_type" }
	function panelControllerProgged:post_panel_domain_set_new_authinfo( params )
		-- код писать тут
		local select_domain = db.query( 'SELECT * FROM domains WHERE name = ?', params.dname )

		local body = {}
		body.nss   = {}

		if #select_domain == 0 then
			return { json = { answer = { domains = error_dict( { code = '2303' }, params.dname ) }, result = 'success' } }
		else
			local split

			if type( select_domain[1].nss ) ~= 'userdata' then
				split = stringx.split( select_domain[1].nss, ';' )

				for _,s in pairs( split ) do
					local ns = stringx.split( s, '#' )[1]
					local ip = stringx.split( s, '#' )[2]

					body.nss[ns] = true

					if ip then
						body.nss[ns] = stringx.split( ip, ',' )
					end
				end
			end
		end


		local response_list = {}

		local tld = string.lower( pathx.extension( params.dname ) ):sub( 2 )

		if config[ TLD[ tld ] ] then
				
			for i,v in pairs( config[ TLD[ tld ] ] ) do
				body[i] = v
			end

			body.name     = params.dname
			body.authInfo = params.authinfo


			
			body.clTRID, block = format.QC_insert( 'domain', 'update', util.to_json( body ), body.name )

			local is_success, fin

			if block then
				body.tr_status = 'block'

				fin = { result = { { code = '4213', msg = 'Объект ожидает выполнения другой операции', reason = str } } }
			else
				is_success, fin = pcall( domain.update, body )
				
				if not is_success then fin = format.err( fin ) end
			end
			
			fin.clTRID = body.clTRID

			db.query( 'UPDATE queueClient SET response = ?, status = ? WHERE id = ?', util.to_json( fin ), body.tr_status, body.clTRID )




			if fin.result[1].code == '1000' then

				table.insert( response_list, fin )
			else
				table.insert( response_list, error_dict( fin.result[1], params.dname ) )
				--table.insert( response_list, error_dict( fin.result[1], v.dname ) )
			end

			--table.insert( response_list, fin )

		else
			local tmp = {
				["dname"]      = params.dname,
        		["error_code"] = "INVALID_DOMAIN_NAME_FORMAT",
        		["error_text"] = params.dname .. " is invalid or unsupported zone",
        		["result"]     = "error"
			}

			table.insert( response_list, tmp )
		end

		return {
			json = {
				response = response_list,
				success = true,
				error = false,
				message = 'NYI; DEBUG: ' .. inspect( params )
			}
		}
	end

	setmetatable( public, self )
	self.__index = self
	return public

end
