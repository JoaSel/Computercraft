--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meMultiBlockRequester.lua

package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")
local mTerm = require("moreTerm")
local dump = require("dump")

local chest = pWrapper.find("minecraft:chest")
local reader = pWrapper.find("blockReader")
local bridge = peripheral.find("meBridge")

local blockData = reader.getBlockData()

local function getRequiredItems(inTags)
	local ret = {}

	for _, item in pairs(inTags) do
		local existingItem = ret[item.id]

		if(existingItem) then
			existingItem.total = existingItem.total + item["#"]
			existingItem.needed = existingItem.needed + item["#"]
		else
			ret[item.id] = { total = item["#"], needed = item["#"]}
		end
	end

	return ret
end

local function adjustExistingItems(requiredItems)
	local existing = chest.list()

	for _, item in pairs(existing) do
		local existingItem = requiredItems[item.name]
		if(existingItem) then
			existingItem.needed = existingItem.needed - item.count
		end
	end
end

local function verifyItem(itemName, itemInfo)
	if(itemInfo.needed <= 0) then
		mTerm.cprint(itemInfo.total .. " " .. itemName, colors.green)
		return
	end

	local searchTbl = { name = itemName }
	local inSystemAmount = 0
	local inSystemItem = bridge.getItem(searchTbl)

	if(inSystemItem and inSystemItem.amount) then
		inSystemAmount = inSystemItem.amount
	end

	if(inSystemAmount >= itemInfo.needed) then
		mTerm.cprint(itemInfo.total .. " " .. itemName, colors.green)
		return false
	end
	if(bridge.isItemCrafting(searchTbl)) then
		mTerm.cprint(itemInfo.total  .. " " .. itemName, colors.yellow)
		return true
	end
	if(bridge.isItemCraftable(searchTbl)) then
		mTerm.cprint(itemInfo.total  .. " " .. itemName, colors.orange)
		bridge.craftItem({ name = itemName, count = itemInfo.needed - inSystemAmount })
		return true
	else
		mTerm.cprint(itemInfo.total .. " " .. itemName, colors.red)
		return false
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

for itemName, itemInfo in pairs(requiredItems) do
	verifyItem(itemName, itemInfo)
end




