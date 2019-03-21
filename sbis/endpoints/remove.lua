local requests = require 'requests'
local date     = require "date"

local EP = {}

EP.POST = function(self)
	local response = requests.get('https://file.gtn.ee/api/v1.0/files/list', {
		params = {
			test = 'kukuzapa sbisin'
		},
        headers = {
            ['Authorization'] = 'Bearer a0f4b317645f90af291a592eaca53eb69d988fa083e00fe98491738aaab554a8',
        }
	}).json()

	local to_remove = 0

	local all = 0

	if response.error then
		return { json = { was = 0, remove = 0, now = 0 } }
	end

	for i,v in pairs( response.files ) do
		all = all + 1
		if date.diff( date(), date( v.created ) ):spanminutes() > 60 then
			to_remove = to_remove + 1
			local response = requests.post('https://file.gtn.ee/api/v1.0/files/delete', {
				json = {
					uid_file = v.uid_file
				},
				headers = {
					['Authorization'] = 'Bearer a0f4b317645f90af291a592eaca53eb69d988fa083e00fe98491738aaab554a8',
				}
			})
		end
	end

	local now = all - to_remove

	return { json = { was = all, remove = to_remove, now = now } }
end

return EP