---@diagnostic disable: need-check-nil

local _input = nil
local _internalBuffer = nil
local _internalBufferSize = 1

local _defaultDestination = nil
local _destinationNames = nil

local _displayNameRoutes = {}
local _tagRoutes = {};
local _miscRoutes = {};

local _verbose = false

local function create(input, internalBuffer, defaultDestination, destinationNames, displayNameRoutes, tagRoutes,
					  miscRoutes, verbose)
	_input = input
	_internalBuffer = internalBuffer
	_internalBufferSize = math.ceil(internalBuffer.size() / 2)

	_defaultDestination = defaultDestination
	_destinationNames = destinationNames

	_displayNameRoutes = displayNameRoutes
	_tagRoutes = tagRoutes
	_miscRoutes = miscRoutes

	_verbose = verbose
end

local function hasTag(item, tag)
	if (item.tags == nil) then
		return false
	elseif (item.tags[tag] == nil) then
		return false
	end
	return true
end

local function getDestination(item)
	local itemDest = _displayNameRoutes[item.displayName]
	if (itemDest ~= nil) then
		print("got _displayNameRoutes")
		return itemDest
	end

	for _, destinationFunc in pairs(_miscRoutes) do
		local dest = destinationFunc(item)
		if(dest) then
			print("got _miscRoutes")
			return dest
		end
	end

	for tag, destination in pairs(_tagRoutes) do
		if (hasTag(item, tag)) then
			return destination
		end
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
	print("Starting to sort...")
	while (true) do
		local currentItems = _internalBuffer.list()
		for slot, item in pairs(currentItems) do
			local detail = _internalBuffer.getItemDetail(slot)
			if (detail ~= nil and detail.displayName ~= nil) then
				local destination = getDestination(detail)

				if(_verbose) then
					print(detail.displayName .. " => " .. destination)
				end

				_internalBuffer.pushItems(_destinationNames[destination], slot, 64)
			end
		end

		addInputItems(_internalBufferSize - #currentItems)
	end
end

return { create = create, run = run, hasTag = hasTag }
