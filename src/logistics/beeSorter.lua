--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/logistics/beeSorter.lua

local dimChests = { peripheral.find("dimstorage:dimensional_chest") }

local inputName = "dimstorage:dimensional_chest_24"
local internalBufferName = "dimstorage:dimensional_chest_8"
local input = nil
local internalBuffer = nil

local destinations = {
	["Centrifuge Input"] = "dimstorage:dimensional_chest_9",
	["Storage Input"] = "dimstorage:dimensional_chest_23",
	["Centrifuge Fluid Input"] = "dimstorage:dimensional_chest_11",
	["Furnace Input"] = "dimstorage:dimensional_chest_12",
	["Compactor Input"] = "dimstorage:dimensional_chest_13",
	["Nugget Input"] = "dimstorage:dimensional_chest_21",
}

local modsToDestination = {
	["chemlib"] = "Compactor Input"
}

local displayNamesToDestination = {
	["Oily Comb Block"] = "Centrifuge Fluid Input",
	["Energized Glowstone Comb Block"] = "Centrifuge Fluid Input",
	["Wasted Radioactive Comb Block"] = "Storage Input",
	["Raw Neodymium"] = "Storage Input",
	["Raw Palladium"] = "Storage Input",
	["Raw Sheldonite"] = "Storage Input",
	["Hydrogen"] = "Storage Input",
	["Oxygen"] = "Storage Input"
}

local tagsToDestination = {
	["forge:storage_blocks/honeycombs"] = "Centrifuge Input",
	["forge:raw_materials"] = "Furnace Input",
	["forge:nuggets"] = "Nugget Input"
}

local function hasTag(item, tag)
	if (item.tags == nil) then
		return false
	elseif (item.tags[tag] == nil) then
		return false
	end
	return item.tags[tag]
end

local function getDestination(item)
	local itemDest = displayNamesToDestination[item.displayName]
	if (itemDest ~= nil) then
		return itemDest
	end

	if (string.match(item.name, "^chemlib")) then
		return "Compactor Input"
	end

	for tag, destination in pairs(tagsToDestination) do
		if (hasTag(item, tag)) then
			return destination
		end
	end
	return "Storage Input"
end

local function init()
	for i = 1, #dimChests do
		if (peripheral.getName(dimChests[i]) == inputName) then
			print("Initialized " .. inputName .. " as input.")
			input = dimChests[i]
		end
		if (peripheral.getName(dimChests[i]) == internalBufferName) then
			print("Initialized " .. internalBufferName .. " as internal buffer.")
			internalBuffer = dimChests[i]
		end
	end
end

local function addInputItems(itemsToAdd)
	local addCount = 0
	if (itemsToAdd < 0) then
		return
	end

	if (input == nil) then
		error("Could not find input.")
	end

	local inputList = input.list()
	local addedItems = 0
	for slot, item in pairs(inputList) do
		input.pushItems(internalBufferName, slot)
		addedItems = addedItems + 1
		if (addedItems >= itemsToAdd) then
			return
		end
	end
end

local function run()
	if (internalBuffer == nil) then
		error("Could not find internalBuffer.")
	end

	while (true) do
		local currentItems = internalBuffer.list()
		for slot, item in pairs(currentItems) do
			local detail = internalBuffer.getItemDetail(slot)
			if (detail ~= nil and detail.displayName ~= nil) then
				local destination = getDestination(detail)
				print(detail.displayName .. " => " .. destination)
				internalBuffer.pushItems(destinations[destination], slot)
			end
		end

		addInputItems(27 - #currentItems)
	end
end

init()
run()
