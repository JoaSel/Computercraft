--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meMultiBlockRequester.lua

package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")
local dump = require("dump")

local chest = pWrapper.find("minecraft:chest")
local reader = pWrapper.find("blockReader")
local bridge = peripheral.find("meBridge")

local blockData = reader.getBlockData()

local function getRequiredItems(inTags)
	local ret = {}

	for _, item in pairs(inTags) do
		if(item.id) then
			ret[item.id] = (ret[item.id] or 0) + item["#"]
		end
	end

	return ret
end

local function adjustExistingItems(requiredItems)
	local existing = chest.list()

	for _, item in pairs(existing) do
		if(requiredItems[item.name] ~= nil) then
			requiredItems[item.name] = requiredItems[item.name] - item.count
		end
	end
end

local function requestItem(itemName, amount, existingItem)
	local craftCount = math.min(requestInfo.batch, requestInfo.amount - existingItem.amount)

	bridge.craftItem({ name = itemName, count = craftCount })

	local event, success, message = os.pullEvent("crafting")
	if success then
		requestInfo.status = "Crafting"
	else
		requestInfo.status = "FailedToStart"
	end
end

print("Press Enter to run.")
--local x = io.read()
local firstItem = blockData.Items[1]
if(not firstItem or firstItem.id ~= "ae2:processing_pattern") then
	print("No pattern found! Put a pattern in first slot.")
	return
end

local requiredItems = getRequiredItems(firstItem.tag["in"])
adjustExistingItems(requiredItems)

for itemName, requiredAmount in pairs(requiredItems) do
	local searchTbl = { name = itemName }
	local inSystemAmount = 0
	local inSystemItem = bridge.getItem(searchTbl)

	if(inSystemItem and inSystemItem.amount) then
		inSystemAmount = inSystemItem.amount
	end

	if(inSystemAmount >= requiredAmount) then
		print("Exporting " .. itemName)
		bridge.exportItem(searchTbl, "up")
	else
		print("Error trying to fix: " .. itemName)
	end
end


dump.easy(requiredItems)


