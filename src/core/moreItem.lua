local function hasTag(item, tag)
	if (item.tags == nil) then
		return false
	elseif (item.tags[tag] == nil) then
		return false
	end
	return true
end

return { hasTag = hasTag }