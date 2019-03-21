-- Шаблон API приложения lapis
local lapis       = require( "lapis" )
local config      = require( "lapis.config" ).get()
local json_params = require( "lapis.application" ).json_params
local tablex      = require( "pl.tablex" )
local jsonschema  = require( 'jsonschema.init' )
local inspect     = require( 'inspect' )
local rh          = require( "ngxreqhelper" )
app               = lapis.Application()
local api_ver     = "0.1"

-- Наследование
function extended ( child, parent )
	setmetatable( child, { __index = parent } ) 
end

-- Вадидация параметра по JSONSchema
function validateParamBySchema ( param, val )
	-- @TODO: костыль для lapis (почему-то не понимает boolean)
	if val == "true" then
		val = true
	elseif val == "false" then
		val = false
	end

	local result = true
	local err = nil
	local sch = param.schema or {}
	local spec = require( "api.spec" )
	sch.components = spec.components
	local validateFunc = jsonschema.generate_validator ( sch, {
		match_pattern = function( s, patt )
			local ret = true
			local m, err = ngx.re.match( s, patt, "iu" )
			if not m or m == nil then
				ret = false
			end
			return ret
		end,
		name = param.name
	} )
	result, err = validateFunc( val )
	local validParamName = param.name or 'param'
	local validParamVal = val
	return result, validParamName, validParamVal, err
end

-- Валидация GET
function validateGETParams ( params, vals )
	local result = true
	local validParams = {}
	local err = nil
	if vals.params == nil or not params.parameters then
		result = true
	else
		table.foreach( params.parameters, function( p, param )
			local validParamName = nil
			local validParamVal = nil
			local checkResult = false
			local checkErr = nil

			if param['$ref'] then
				local ref = string.gsub( param['$ref'], '#/', '' )
				ref = string.gsub( ref, '/', '"]["' )
				local parsedParamFn = loadstring( 'local tablex  = require( "pl.tablex" ); local spec = require( "api.spec" ); return tablex.deepcopy( spec["' .. ref .. '"] )' )
				local parsedParam = parsedParamFn()
				if (vals.params[parsedParam.name]) then
					checkResult, validParamName, validParamVal, checkErr = validateParamBySchema( parsedParam, vals.params[parsedParam.name] )
				end
			else
				if vals.params[param.name] then
					checkResult, validParamName, validParamVal, checkErr = validateParamBySchema( param, vals.params[param.name] )
				end
			end
			if not checkResult and checkErr then
				result = false
				err = checkErr
			end
			if validParamName then
				validParams[validParamName] = validParamVal
			end
			
		end )
	end
	return result, validParams, err
end

-- Валидация POST
function validatePOSTParams ( params, vals )
	local result = true
	local validParams = {}
	local err = nil

	if params.requestBody ~= nil and params.requestBody.content ~= nil then
		table.foreach( params.requestBody.content, function( c, content_handler )
			local validParamName = nil
			local validParamVal = nil
			local checkResult = false
			local checkErr = nil

			-- application/json
			if c:lower() == 'application/json' and rh.isJSON() then
				checkResult, validParamName, validParamVal, checkErr = validateParamBySchema( content_handler, rh.getJSON() )
				if not checkResult and checkErr then
					result = false
					err = checkErr
				end
			end

			-- application/xml
			if c:lower() == 'application/xml' and rh.isXML() then
				-- result, err = validateParams( content_handler, rh.getXML() ) -- @TODO
				print(' warning: XML requests is unsupported yet ')
			end

			-- text/plain
			if c:lower() == 'text/plain' and rh.isText() then
				-- result, err = validateParams( content_handler, rh.getText() ) -- @TODO
				print(' warning: Text requests is unsupported yet ')
			end

			-- application/x-www-form-urlencoded
			if c:lower() == 'application/x-www-form-urlencoded' and rh.isFormURLEncoded() then
				-- result, err = validateParams( content_handler, rh.getFormURLEncoded() ) -- @TODO
				print(' warning: Form URL encoded requests is unsupported yet ')
			end

			-- multipart/form-data
			if c:lower() == 'multipart/form-data' then
				checkResult, validParamName, validParamVal, checkErr = validateParamBySchema( content_handler, vals.POST )
			end

			if validParamName then
				validParams[validParamName] = validParamVal
			end

		end )
	end

	if vals.params and params.parameters then
		table.foreach( params.parameters, function( p, param )
			local validParamName = nil
			local validParamVal = nil
			local checkResult = false
			local checkErr = mil

			if param['$ref'] then
				local ref = string.gsub( param['$ref'], '#/', '' )
				ref = string.gsub( ref, '/', '"]["' )
				local parsedParamFn = loadstring( 'local tablex  = require( "pl.tablex" ); local spec = require( "api.spec" ); return tablex.deepcopy( spec["' .. ref .. '"] )' )
				local parsedParam = parsedParamFn()
				if (vals.params[parsedParam.name]) then
					checkResult, validParamName, validParamVal, checkErr = validateParamBySchema( parsedParam, vals.params[parsedParam.name] )
				end
			else
				if vals.params[param.name] then
					checkResult, validParamName, validParamVal, checkErr = validateParamBySchema( param, vals.params[param.name] )
				end
			end
			if not checkResult and checkErr then
				result = false
				err = checkErr
			end
			if validParamName then
				validParams[validParamName] = validParamVal
			end
			
		end )
	end

	return result, validParams, err
end

-- Валидация параметров
function validateParams ( method, params, vals )
	local result = true
	local validParams = {}
	local err = ''

	if method:lower() == 'get' then
		result, validParams, err = validateGETParams ( params, vals )
	elseif method:lower() == 'post' then
		result, validParams, err = validatePOSTParams ( params, vals )
	end
	-- @TODO реализовать поддержку других методов

	return result, validParams, err
end

-- CORS
app:before_filter( function( self )
	self.res.headers[ "access-control-allow-origin" ]      = config.access_control_allow_origin or "*"
	self.res.headers[ "access-control-max-age" ]           = config.access_control_max_age or 3600
	self.res.headers[ "access-control-allow-credentials" ] = config.access_control_allow_credentials or "true"
	self.res.headers[ "access-control-allow-headers" ]     = config.access_control_allow_headers or "Authorization, Content-Type, X-Requested-With"

	if self.req.cmd_mth == "OPTIONS" then
		self:write( {
			layout = false, headers = {
				["access-control-allow-methods"] = "GET,HEAD,POST",
			}
		} )
		return
	end

	local kyc = require 'module.kyc'

	if self.req.parsed_url.path ~= '/' and not string.find( self.req.parsed_url.path, '/vacation/link/' ) and self.req.parsed_url.path ~= '/vm/admin/link' then
		if not kyc.auth_check( self.req ) then
			self:write( { redirect_to = self:url_for("layout") } )
		end
	end
end )

-- Роутинг
require( "api.routing" )

-- Валидация
require( "api.validate" )

-- Всё остальное у нас 404
function app:handle_404()
	return validateResult ( false, true, "Wrong call." )
end

return app
