local db = require("lapis.db")
--local stringx = require 'pl.stringx'
--local tablex = require 'pl.tablex'
local http = require("lapis.nginx.http")
local util = require("lapis.util")

local inspect = require 'inspect'

local headers = {
	["Authorization"] = "Bearer 24e089b91adce598c0ea3f5c8057dd9c0a54e937b9198c2bd16df9deea7b44f0",
	['Content-Type'] = 'application/json'
}

local provider = "ab17d67c-d11f-11e8-ba29-efa683cf4956"

--local URL = 'https://otpusk.gtn.ee/'
--local URL = 'http://localhost:8080/'
--local URL = 'localhost/'

--print('DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD ' .. ngx.var.scheme )

local URL = 'https://' .. ngx.req.get_headers()["Host"]
--local URL = 'http://' .. ngx.req.get_headers()["Host"]

function send_mail( subject, send_to, mail )
	
	local mail = {
		["uid_provider"] = provider,
		["send_to"] = send_to,
		["subject"] = subject,
		["html"] = mail
	}

	local body, status_code, headers_res = http.simple({
		url = "https://mailer.gtn.ee/api/v1.0/mail",
		method = "POST",
		headers = headers,
		body = util.to_json( mail )
	})
end

local mail = {}

	--Отправка уведомлений на создание заявки
	function mail.send( userid, b_date, e_date, vac_type, vacid, cross, comment )

		local admin_mails = db.query( 'SELECT id,name,email FROM users WHERE isadmin = 1' )

		local user = db.query( 'SELECT name,email FROM users WHERE id = ?', userid )[1]

		if vac_type == 1 then
			vac_type = 'ежегодный (основной) оплачиваемый отпуск'
		end
		if vac_type == 2 then
			vac_type = 'отпуск без сохранения заработной платы'
		end

		local str = string.format( 'Пользователь %s создал заявку на %s с %s по %s.</p>',
			user.name, vac_type, b_date, e_date )

		local send_to = {}

		local subject = 'Уведомление о новой заявке'

		for i,v in pairs( admin_mails ) do
			
			local url = URL .. '/vacation/link/' .. v.id .. '/' .. vacid

			local tmp = '<p><a href="' .. url .. '">Подробная информация о заявке</a></p>'

			send_mail( subject, { v.email }, str .. tmp )
			--send_mail( subject, { 'et@get-net.ru' }, str .. tmp )
		end

		local str = string.format( '<p>Ваша заявка на %s с %s по %s была отправлена на рассмотрение администратору.</p>', vac_type, b_date, e_date )
		
		send_mail( subject, { user.email }, str )
	end

	--Уведомление на отзыв заявки
	function mail.cancel( userid, vacid, b_date, e_date, vac_type )

		local admin_mails = db.query( 'SELECT id,name,email FROM users WHERE isadmin = 1' )

		local user = db.query( 'SELECT name,email FROM users WHERE id = ?', userid )[1]

		local subject = 'Уведомление об отзыве заявки'

		local mail = string.format( '<p>Пользователь %s отозвал свою заявку на %s с %s по %s.</p>',
			user.name, vac_type, b_date, e_date )

		local send_to = {}

		for i,v in pairs( admin_mails ) do
			--table.insert( send_to, v.email )
			local url = URL .. '/vacation/link/' .. v.id .. '/' .. vacid

			local tmp = '<p><a href="' .. url .. '">Подробная информация о заявке</a></p>'

			send_mail( subject, { v.email }, mail .. tmp )
			--send_mail( subject, { 'et@get-net.ru' }, mail .. tmp )
		end
		
		--send_mail( subject, send_to, mail )

		local mail = string.format( 'Вы отозвали свою заявку на %s с %s по %s.', vac_type, b_date, e_date )

		send_mail( subject, { user.email }, mail )
	end

	--Уведомление о принятии решения
	function mail.admin( userid, vacid, status )
		
		--Имя пациента и его ящик
		local clname = db.query( [[SELECT u.email,u.name,vt.type,v.begin,v.end FROM vacations v 
			INNER JOIN users u ON v.user_id = u.id 
			INNER JOIN vac_type vt ON v.vac_type_id = vt.id
			WHERE v.id = ?]], vacid )[1]

		--Имя администратора, принявшего решение, и его ящик
		local adname = db.query( 'SELECT name,email FROM users WHERE id = ?', userid )[1]

		--Ящики всех админов
		local admin_mails = db.query( 'SELECT id,name,email FROM users WHERE isadmin = 1' )

		local tmp = ''

		if status == '1' then
			status = 'одобрил'
			tmp = 'Желаем приятного отпуска!'
		else
			status = 'отклонил'
			tmp = 'Желаем вам дальнейших успехов в труде и творчестве!'
		end

		--Письмо для пациента
		local subject = 'Изменение статуса заявки'

		local mail = string.format( '<p>%s, администратор %s %s вашу заявку на %s с %s по %s. %s</p>',
			clname.name, adname.name, status, clname.type, clname.begin, clname['end'], tmp )

		send_mail( subject, { clname.email }, mail )

		--Письмо для принявшего решение
		local mail = string.format( '<p>Вы %sи зявку пользователя %s на %s с %s по %s.</p>',
			status, clname.name, clname.type, clname.begin, clname['end'] )

		send_mail( subject, { adname.email }, mail )

		--Письмо для остальных администраторов
		local mail = string.format( '<p>Администратор %s %s заявку пользователя %s на %s с %s по %s.</p>',
			adname.name, status, clname.name, clname.type, clname.begin, clname['end'] )

		local send_to = {}

		if #admin_mails > 1 then
			for i,v in pairs( admin_mails ) do
				if v.email ~= adname.email then
					local url = URL .. '/vacation/link/' .. v.id .. '/' .. vacid

					local tmp = '<p><a href="' .. url .. '">Подробная информация о заявке</a></p>'

					send_mail( subject, { v.email }, mail .. tmp )
				end
			end
		end

		--send_mail( subject, send_to, mail )

	end

return mail