local function toDisplayName(name)
	if(not name) then
		return nil
	end
	
	if (string.byte(string.sub(name, 1, 1)) == 167) then
		return string.sub(string.sub(name, 0, #name - 3), 3)
	end

	return name
end

return { toDisplayName = toDisplayName }
