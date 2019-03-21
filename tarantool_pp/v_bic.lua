local xmlx = require 'pl.xml'
local inspect = require 'inspect'

local iconv = require 'iconv'

local lom,err = xmlx.parse('/home/kukuzapa/work/tests/20181221_ED807_full.xml', true, false)
--local lom = xmlx.parse("<nodes><node id='1'>alice</node></nodes>",false,false)
if err then
	print( err )

else

	--print( inspect( lom) )



end

local fin = {}

for _,u in pairs( lom ) do

	local tmp = {}

	if u.tag then

		

		print( u.attr.BIC )

		tmp.BIC = u.attr.BIC

		for i,v in pairs( u ) do

			--if v.tag == 'ed:Accounts' then
			--	print( v.attr.Account )
			--end

			if v.tag == 'ed:ParticipantInfo' then
				--print( v.attr.NameP )

				--cd = iconv.new('utf-8', 'cp1251')
				cd = iconv.open('utf-8', 'cp1251')

				nstr, err = cd:iconv(v.attr.NameP)

				print( nstr, err )

				tmp.name = nstr
			end

		end
		--print( v.tag )
		
	end

	table.insert( fin, tmp )

	print('--------------------------------------------------------')
	
end

--[[print('-----------------------')

for i,v in pairs( lom[1] ) do

	print(i)

end



print( inspect( lom[10] ) )

print( '````````````````````````````````````````````````' )

print( lom[10].attr.BIC )

for i,v in pairs( lom[10] ) do
	if v.tag then
		--print( v.tag )
		if v.tag == 'ed:Accounts' then
			print( v.attr.Account )
		end

		if v.tag == 'ed:ParticipantInfo' then
			print( v.attr.NameP )

			--cd = iconv.new('utf-8', 'cp1251')
			cd = iconv.open('utf-8', 'cp1251')

			nstr, err = cd:iconv(v.attr.NameP)

			print( nstr, err )
		end
	end

end]]

--cd = iconv.new(to, from)
--cd = iconv.open(to, from)

print( inspect( fin ) )