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
		if(item.id) then
			local existingItem = ret[item.id]

			if(existingItem) then
				existingItem.total = existingItem.total + item["#"]
				existingItem.needed = existingItem.needed + item["#"]
			else
				ret[item.id] = { total = item["#"], needed = item["#"]}
			end
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

local function handleItem(itemName, itemInfo)
	if(itemInfo.needed <= 0) then
		return "Exported"
	end

	local searchTbl = { name = itemName }
	local inSystemAmount = 0
	local inSystemItem = bridge.getItem(searchTbl)

	if(inSystemItem and inSystemItem.amount) then
		inSystemAmount = inSystemItem.amount
	end

	if(inSystemAmount >= itemInfo.needed) then
		bridge.exportItem({ name = itemName, count =  itemInfo.needed}, "up")
		return "InSystem"
	end
	if(bridge.isItemCrafting(searchTbl)) then
		return "Crafting"
	end
	if(bridge.isItemCraftable(searchTbl)) then
		bridge.craftItem({ name = itemName, count = itemInfo.needed - inSystemAmount })
		return "Craftable"
	else
		return "Error"
	end
end

local colorTable = {
	["Exported"] = colors.green,
	["InSystem"] = colors.green,
	["Crafting"] = colors.yellow,
	["Craftable"] = colors.orange,
	["Error"] = colors.red,
}
local function render(requiredItems)
	for itemName, itemInfo in pairs(requiredItems) do
		mTerm.cprint(itemInfo.total .. " " .. itemName, colorTable[itemInfo.status])
	end
end
while (true) do
	print("Press Enter to run.")
	local x = io.read()

	local firstItem = blockData.Items[1]
	if (not firstItem or firstItem.id ~= "ae2:processing_pattern") then
		print("No pattern found! Put a pattern in first slot.")
	else
		local requiredItems = getRequiredItems(firstItem.tag["in"])
		adjustExistingItems(requiredItems)

		local done = true
		while not done do
			for itemName, itemInfo in pairs(requiredItems) do
				itemInfo.status = handleItem(itemName, itemInfo)
				if (itemInfo.status ~= "Exported") then
					done = false
				end
			end

			render(requiredItems)
			os.sleep(5)
		end
	end
end
