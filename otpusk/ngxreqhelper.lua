-- Хэлпер запросов ngx
local tablex = require( "pl.tablex" )
local cjson  = require( "cjson" )

ngxReqHelper = {
}

-- Наш запрос типа Text ?
function ngxReqHelper:isText()
	local ret = false
	local rh = ngx.req.get_headers()
	table.foreach( rh, function( i, v )
		if i:lower() == 'content-type' then
			if v:lower():match('text/plain') then
				ret = true
			end
		end
	end )
	return ret
end

-- Наш запрос типа JSON ?
function ngxReqHelper:isJSON()
	local ret = false
	local rh = ngx.req.get_headers()
	table.foreach( rh, function( i, v )
		if i:lower() == 'content-type' then
			if v:lower():match('application/json') then
				ret = true
			end
		end
	end )
	return ret
end

-- Наш запрос типа XML ?
function ngxReqHelper:isXML()
	local ret = false
	local rh = ngx.req.get_headers()
	table.foreach( rh, function( i, v )
		if i:lower() == 'content-type' then
			if v:lower():match('application/xml') then
				ret = true
			end
		end
	end )
	return ret
end

-- Наш запрос типа application/x-www-form-urlencoded ?
function ngxReqHelper:isFormURLEncoded()
	local ret = false
	local rh = ngx.req.get_headers()
	table.foreach( rh, function( i, v )
		if i:lower() == 'content-type' then
			if v:lower():match('application/x-www-form-urlencoded') then
				ret = true
			end
		end
	end )
	return ret
end

-- Наш запрос типа multipart/form-data
function ngxReqHelper:isFormMultipart()
	local ret = false
	local rh = ngx.req.get_headers()
	table.foreach( rh, function( i, v )
		if i:lower() == 'content-type' then
			if v:lower():match('multipart/form-data') then
				ret = true
			end
		end
	end )
	return ret
end

-- Возвращает JSON из тела запроса
function ngxReqHelper:getJSON()
	local ret = nil
	ngx.req.read_body()
	if ngx.var.request_body ~= nil then
		local text = ngx.var.request_body
		ret = cjson.new().decode( text )
	end
	return ret
end

return ngxReqHelper