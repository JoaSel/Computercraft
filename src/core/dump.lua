-- local function dump(o)
-- 	if type(o) == 'table' then
-- 		local s = '{ '
-- 		for k, v in pairs(o) do
-- 			if type(k) ~= 'number' then k = '"' .. k .. '"' end
-- 			s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
-- 		end
-- 		return s .. '} '
-- 	else
-- 		return tostring(o)
-- 	end
-- end

-- local function printDump(o)
-- 	print(dump(o))
-- end

local function serialise(o)
	return textutils.serialise(o, { allow_repetitions = true })
end

local function print(o)
	print(serialise(o))
end


local function toFile(o, filename)
	local data = serialise(o)

	local file = fs.open(filename, "w+")
	file.write(data)
	file.close()
end

local function shallow(o)
	if type(o) == 'table' then
		print('{ ')
		for k, v in pairs(o) do
			if type(k) ~= 'number' then k = '"' .. k .. '"' end
			print('\t[' .. k .. '] = ' .. tostring(v) .. ',')
		end
		print('} ')
	else
		print(tostring(o))
	end
end

return { print = print, shallow = shallow, toFile = toFile }
