local function dump(o)
	if type(o) == 'table' then
		local s = '{ '
		for k, v in pairs(o) do
			if type(k) ~= 'number' then k = '"' .. k .. '"' end
			s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end

local function printDump(o)
	print(dump(o))
end

local function easy(o)
	print(textutils.serialise(o, { allow_repetitions = true }))
end

return { dump = dump, printDump = printDump, easy = easy }
