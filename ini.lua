ini = {}

function ini.magicLines(str)

	if str:sub(-1) ~= '\n' then str = str.."\n" end

	--this is a very weird fix I don't know why 13 fucks up the patterns I think it's \r idk too lazy to fix
	for i=1,#str do
		if string.byte(str:sub(i,i)) == 13 then
			str = str:sub(1,i-1) .. str:sub(i+1,#str)
		end
	end

	return str:gmatch(("(.-)\n"))
end

function ini.read(path)

	assert(type(path) == 'string','Path must be a string!')

	local path = path..'.txt'

	local iniOpen = assert(file.Read(path,'DATA'),('Error opening file with path: %s'):format(path))
	local data = {}
	local section

	for line in ini.magicLines(iniOpen) do
		
		local tempSection = line:match('^%[([^%[%]]+)%]$')

		if tempSection then
			
			section = tonumber(tempSection) and tonumber(tempSection) or tempSection
			data[section] = data[section] or {}
		end

		local param, val = line:match('^([%w|_]+)%s-=%s-(.+)$')


		if param and val ~= nil then

			local digits = val:gmatch("%d+")

			local vars = {}
			local letter = 'w'
			for digit in digits do
				
				vars[letter] = tonumber(digit)
				letter = letter == 'w' and 'x' or letter == 'x' and 'y' or 'z'
			end

			local w,x,y,z = vars.w,vars.x,vars.y,vars.z

			if w and x and y and z then

				val = Color(w,x,y,z)
			elseif val:sub(1,6) == 'Vector' and w and x and y then

				val = Vector(w,x,y)
			elseif val:sub(1,5) == 'Color' and w and x and y then

				val = Color(w,x,y)
			elseif val:sub(1,5) == 'Angle' and w and x and y then

				val = Angle(w,x,y)
			elseif tonumber(val) then
				
				val = tonumber(val)
			elseif val == 'true' then
				
				val = true
			elseif val == 'false' then
				
				val = false
			elseif val:sub(1,1) == '%' and val:sub(-1) == '%' then
				
				local var = val:sub(2,#val-1)

				print(var)
				if _G[var] then
					
					val = _G[var]
				end


			end

			if tonumber(param) then
				
				param = tonumber(param)
			end

			data[section][param] = val
		end
	end

	return data
end

function ini.write(name,tbl)

	assert(type(name) == 'string', 'Name should be a string!')
	assert(type(tbl) == 'table', 'Content should be a table!')

	local content = ''

	for section, param in pairs(tbl) do
		
		content = content..('[%s]\r\n'):format(section)

		for k, v in pairs(param) do
			
			local append = tostring(v)

			if type(v) == 'Vector' then
				
				append = ('Vector(%i,%i,%i)'):format(v.x,v.y,v.z)
			elseif type(v) == 'Color' then
				
				if v.a then
					
					append = ('Color(%i,%i,%i,%i)'):format(v.r,v.g,v.b,v.a)
				else

					append = ('Color(%i,%i,%i'):format(v.r,v.g,v.b)
				end
			elseif type(v) == 'Angle' then

				append = ('Angle(%i,%i,%i)'):format(v.p,v.y,v.r)
			end
			
			content = content..('%s=%s\r\n'):format(k,append)
		end
		content = content..'\r\n'
	end

	file.Write(name..'.txt',content)
end
