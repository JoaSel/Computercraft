local function text2(o)
	if type(o) == 'table' then
		local s = '{ '
		for k, v in pairs(o) do
			if type(k) ~= 'number' then k = '"' .. k .. '"' end
			s = s .. '[' .. k .. '] = ' .. text2(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end



local function text(o)
	return textutils.serialise(o, { allow_repetitions = true })
end

local function toTerm(o)
	print(text(o))
end

local function toTerm2(o)
	print(text2(o))
end


local function toFile(o, filename)
	local data = text(o)

	local file = fs.open(filename, "w+")
	file.write(data)
	file.close()
end

local function toPastebin(o)
	local data = text(o)

	local file = fs.open("pastebinData", "w+")
	file.write(data)
	file.close()

	shell.run("pastebin put \"pastebinData\"")
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

return { toTerm = toTerm, toTerm2 = toTerm2, shallow = shallow, toFile = toFile, toPastebin = toPastebin, text = text }
