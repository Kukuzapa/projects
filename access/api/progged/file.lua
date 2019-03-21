-- Менеджер паролей

-- Отладка
local inspect = require( 'inspect' )

local requests = require('requests')

--local file_storage_uid = require("lapis.config").get().file_storage_uid

local helpers = require 'module.helpers'

local stringx = require 'pl.stringx'

local db = require("lapis.db")

local util = require("lapis.util")

fileControllerProgged = {}
function fileControllerProgged:new( params )
	local private = {}
	local public = {}

	-- add file
	-- {}
	function fileControllerProgged:post_file_add( params )

		if not helpers.check_grant( params.param.id, params.param.node, 'update' ) then
			return { json = { err = 'Вы не можете давать права доступа на данный узел' } }
		end
		
		local data
		
		if params.param.type == 'text' then
			data = {
				text_content = params.param.file.content,
				text_filename = stringx.replace( params.param.file.filename, '"', "'" ),
				
				node_name = params.param.node,
				user_id = params.param.id,
				type = params.param.type,
			}
		else
			data = {
				
				uploaded_file = {
					filename = stringx.replace( params.param.file.filename, '"', "'" ),
					content_type = params.param.file['content-type'],
					data = params.param.file.content
				},
		
				--text_content = params.param.file.content,
				--text_filename = params.param.file.filename,
				
				node_name = params.param.node,
				user_id = params.param.id,
				type = params.param.type,
			}

			--return { json = params.param }
		end
	
		local response = requests.post('https://file.gtn.ee/file/upload', {
			form = data,
			headers = {
				['Authorization'] = 'Bearer ' .. params.param.token,
			}
		}).json()

		--if params.param.type == 'text' then

		--else
			
		--end

		if not response.error then
			--db.query( 'DELETE FROM files WHERE uid_file = ?', params.param.file )

			db.query( [[INSERT INTO files (file_type,uid_file,userid,nodeid,file_link,file_name) VALUES (
				?,?,(SELECT id FROM users WHERE userid = ?),
				(SELECT id FROM nodes WHERE node = ?),?,?)]],
				params.param.type, response.new_file.uid, params.param.id, params.param.node, response.new_file.link, 
				stringx.replace( params.param.file.filename, "'", '"' ) )

			return { json = { success = 'Файл успешно удален' } }
		end
	
		return { json = response }
	end

	-- add file
	-- {}
	function fileControllerProgged:post_file_remove( params )

		local fin = {}
		
		local response = requests.post( 'https://file.gtn.ee/api/v1.0/files/delete', {
			json = {
				uid_file = params.param.file
			},
			headers = {
				['Authorization'] = 'Bearer ' .. params.param.token,
			}
		}).json()

		if not response.error then
			db.query( 'DELETE FROM files WHERE uid_file = ?', params.param.file )

			return { json = { success = 'Файл успешно удален' } }
		else
			return { json = response }
		end
		

		--return {
		--	json = { params = params, response = response }
		--}
	end

	-- file list
	-- { "id", "node" }
	function fileControllerProgged:get_file_list( params )

		if not helpers.check_grant( params.id, params.node, 'read' ) then
			return { json = { err = 'Вы не можете давать права доступа на данный узел' } }
		end

		local sel

		if params.type == 'text' then
			sel = db.query( [[SELECT f.uid_file,f.file_link,u.userid,f.file_name FROM files f
				INNER JOIN nodes n ON f.nodeid = n.id
				INNER JOIN users u ON f.userid = u.id
				WHERE n.node = ? AND f.file_type = ?]], params.node, params.type )

			for i,v in pairs( sel ) do
				--sel[i].tst = requests.get( v.file_link ).text
				local tmp = requests.get( v.file_link ).text
				sel[i].tst = util.from_json( tmp ).content
			end
		else
			--sel = db.query( 'SELECT * FROM files WHERE nodeid = (SELECT id FROM nodes WHERE node = ?) AND file_type = ?',
			--	params.node, params.type )
			sel = db.query( [[SELECT f.uid_file,f.file_link,u.userid,f.file_name FROM files f
				INNER JOIN nodes n ON f.nodeid = n.id
				INNER JOIN users u ON f.userid = u.id
				WHERE n.node = ? AND f.file_type = ?]], params.node, params.type )
		end

		return { json = sel }
	end

	setmetatable( public, self )
	self.__index = self
	return public

end
