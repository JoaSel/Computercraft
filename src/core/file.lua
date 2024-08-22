local function readAll(path)
	local filestream = fs.open(path, "r")
	if (not filestream) then
		error("Could not open stream on " .. path)
	end

	return filestream.readAll()
end

local function readAllAndParse(path)
	local content = readAll(path)

	local parsed = textutils.unserialize(content)
	if (not parsed) then
		error("Could not unserialize request data from " .. path)
	end

	return parsed
end

return { readAll = readAll, readAllAndParse = readAllAndParse }
