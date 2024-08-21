---@diagnostic disable: need-check-nil

local _input = nil
local _internalBuffer = nil
local _internalBufferSize = 1

local _defaultDestination = nil
local _destinationNames = nil

local _displayNameRoutes = {}
local _tagRoutes = {};
local _miscRoutes = {};

local function create(input, internalBuffer, defaultDestination, destinationNames, displayNameRoutes, tagRoutes,
					  miscRoutes)
	_input = input
	_internalBuffer = internalBuffer
	_internalBufferSize = math.ceil(internalBuffer.size() / 2)

	_defaultDestination = defaultDestination
	_destinationNames = destinationNames

	_displayNameRoutes = displayNameRoutes
	_tagRoutes = tagRoutes
	_miscRoutes = miscRoutes
end

local function hasTag(item, tag)
	if (item.tags == nil) then
		return false
	elseif (item.tags[tag] == nil) then
		return false
	end
	return item.tags[tag]
end

local function getDestination(item)
	local itemDest = _displayNameRoutes[item.displayName]
	if (itemDest ~= nil) then
		return itemDest
	end

	for tag, destination in pairs(_tagRoutes) do
		if (hasTag(item, tag)) then
			return destination
		end
	end

	if (string.match(item.name, "^gtceu:") and hasTag(item, "forge:ores")) then
		return "Macerator"
	end

	return _defaultDestination
end

local function addInputItems(itemsToAdd)
	if (itemsToAdd < 0) then
		return
	end

	local inputItems = _input.list()
	local addedItems = 0
	for slot, item in pairs(inputItems) do
		_input.pushItems(peripheral.getName(_internalBuffer), slot)
		addedItems = addedItems + 1
		if (addedItems >= itemsToAdd) then
			return
		end
	end
end


local function run()
	while (true) do
		local currentItems = _internalBuffer.list()
		for slot, item in pairs(currentItems) do
			local detail = _internalBuffer.getItemDetail(slot)
			if (detail ~= nil and detail.displayName ~= nil) then
				local destination = getDestination(detail)
				print(detail.displayName .. " => " .. destination)
				_internalBuffer.pushItems(_destinationNames[destination], slot, 64)
			end
		end

		addInputItems(_internalBufferSize - #currentItems)
	end
end

return { create = create, run = run }
