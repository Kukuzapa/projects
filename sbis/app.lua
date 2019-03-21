local lapis = require("lapis")
local app = lapis.Application()

--local http = require("lapis.nginx.http")

--local inspect = require 'inspect'

--local request = require 'module.request'

--local stringx = require 'pl.stringx'

--local encoding = require("lapis.util.encoding")
--local util     = require("lapis.util")
--local db = require("lapis.db")

--local requests = require 'requests'
local config   = require( "lapis.config" ).get()





local respond_to    = require("lapis.application").respond_to

--ENDPOINTS
local logs = require 'endpoints.logs'
local queue = require 'endpoints.queue'
local remove = require 'endpoints.remove'
local list = require 'endpoints.list'
local att = require 'endpoints.att'
local accrej = require 'endpoints.accrej'
local massaccept = require 'endpoints.massaccept'
----END----


--Просмотр состояния загруженных исходящих файлов
app:get( '/logs', respond_to( logs ) )

--Загрузка файлов для отправки контрагентам
app:post( '/queue', respond_to( queue ) )


app:post( '/remove', respond_to( remove ) )

app:get( '/list', respond_to( list ) )
app:get( '/att', respond_to( att ) )
app:post( '/accrej', respond_to( accrej ) )
app:post( '/massaccept', respond_to( massaccept ) )






--CORS
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
end )
----END----

--Авторизация через KYC
app:before_filter( function( self )
	local kyc = require 'module.kyc'

	if self.req.parsed_url.path ~= '/' then
		if not kyc.auth_check( self.req ) then
			self:write( { redirect_to = self:url_for("layout") } )
		end
	end
end )
----END----

--Шаблон фронта
app:match('layout',"/(*)", function()
	app:enable("etlua")
	app.layout = require "views.layout"
	return { render = true }
end)
----END----

return app