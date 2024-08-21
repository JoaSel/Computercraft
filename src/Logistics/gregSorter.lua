--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua gregSorter

local internalBuffer = peripheral.find("entangled:tile")
local input = peripheral.find("dankstorage:dank_tile")
local dimChests = { peripheral.find("dimstorage:dimensional_chest") }

local destinations = {
	["Macerator"] = "dimstorage:dimensional_chest_15",
	["Washer"] = "dimstorage:dimensional_chest_16",
	["Thermal Centrifuge"] = "dimstorage:dimensional_chest_17",
	["Storage Input"] = "dimstorage:dimensional_chest_20",
	["Centrifuge Input"] = "dimstorage:dimensional_chest_22"
}

local displayNamesToDestination = {
	["Crushed Rock Salt Ore"] = "Thermal Centrifuge",
	["Purified Sheldonite Ore"] = "Storage Input",
	["Rare Earth Dust"] = "Centrifuge Input",
	["Raw Neodymium"] = "Storage Input",
	["Purified Sphalerite Ore"] = "Storage Input",
	["Purified Galena Ore"] = "Storage Input",
	["Red Granite Salt Ore"] = "Storage Input"
}

local tagsToDestination = {
	["forge:crushed_ores"] = "Washer",
	["forge:purified_ores"] = "Thermal Centrifuge",
	["forge:refined_ores"] = "Macerator"
}

local function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
 end

local function printDump(o) 
	print(dump(o))
end

local function hasTag(item, tag)
    if(item.tags == nil) then
        return false
    elseif(item.tags[tag] == nil) then
        return false
    end
    return item.tags[tag]
end

local function getDestination(item)
	local itemDest = displayNamesToDestination[item.displayName]
	if(itemDest ~= nil) then
		return itemDest
	end
	
	for tag, destination in pairs(tagsToDestination) do
		if(hasTag(item, tag)) then
			return destination
		end
	end
	
	if(string.match(item.name, "^gtceu:") and hasTag(item, "forge:ores")) then
        return "Macerator"
    end

	return "Storage Input"
end

local function addInputItems(itemsToAdd)
    local addCount = 0
    if(itemsToAdd < 0) then
        return
    end
 
    local inputList = input.list()
    local addedItems = 0
    for slot, item in pairs(inputList) do
        input.pushItems(peripheral.getName(internalBuffer), slot)
        addedItems = addedItems + 1
        if(addedItems >= itemsToAdd) then
            return
        end
    end
end


local function run() 
	while(true) do
    	local currentItems = internalBuffer.list()
		for slot, item in pairs(currentItems) do
			local detail = internalBuffer.getItemDetail(slot)
			if(detail ~= nil and detail.displayName ~= nil) then
				local destination = getDestination(detail)
				print(detail.displayName .. " => " .. destination)
				internalBuffer.pushItems(destinations[destination], slot, 64)
			end			
    	end

	
		addInputItems(27 - #currentItems)
	end
end

run()