local function getTable(url)
	local socket = http.get(url)
	if (not socket) then
		error("Could not create socket for " .. url)
	end

	local content = socket.readAll()
	if (not content) then
		error("Could not read on " .. url)
	end

	socket.close()

	local parsed = textutils.unserialize(content)
	if (not parsed) then
		error("Could not unserialize request data from " .. url)
	end

	return parsed
end

local function getJson(url)
	local socket = http.get(url)
	if (not socket) then
		error("Could not create socket for " .. url)
	end

	local content = socket.readAll()
	if (not content) then
		error("Could not read on " .. url)
	end

	socket.close()

	local parsed = textutils.unserializeJSON(content)
	if (not parsed) then
		error("Could not unserialize request data from " .. url)
	end

	return parsed
end

return { getTable = getTable, getJson = getJson }
