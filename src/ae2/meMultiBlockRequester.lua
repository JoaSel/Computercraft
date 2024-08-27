--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meMultiBlockRequester.lua

package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")
local mTerm = require("moreTerm")
local dump = require("dump")

local chest = pWrapper.find("minecraft:chest")
local reader = pWrapper.find("blockReader")
local bridge = peripheral.find("meBridge")

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

	for _, existingItem in pairs(requiredItems) do
		existingItem.needed = existingItem.total
	end

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
	term.clear()
	for itemName, itemInfo in pairs(requiredItems) do
		mTerm.cprint(string.format("%d of %d %s", itemInfo.needed, itemInfo.total, itemName), colorTable[itemInfo.status])
	end
end

while (true) do
	print("Press Enter to run.")
	local x = io.read()

	local blockData = reader.getBlockData()

	dump.shallow(blockData)

	local firstItem = blockData.Items[1]
	if (not firstItem or firstItem.id ~= "ae2:processing_pattern") then
		print("No pattern found! Put a pattern in first slot.")
	else
		local requiredItems = getRequiredItems(firstItem.tag["in"])

		repeat
			adjustExistingItems(requiredItems)

			local done = true
			for itemName, itemInfo in pairs(requiredItems) do
				itemInfo.status = handleItem(itemName, itemInfo)
				if (itemInfo.status ~= "Exported") then
					done = false
				end
			end

			render(requiredItems)
			os.sleep(5)
		until done
	end
end
