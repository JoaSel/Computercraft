--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meTagRequester.lua

package.path = package.path .. ";../core/?.lua"

local dump = require("dump")
local mMon = require("moreMonitor")
local aeNameUtil = require("libs.aeNameUtil")

local bridge = peripheral.find("meBridge")
local monitor = peripheral.find("monitor")

local function hasTag(item, tag)
	if (not item.tags) then
		return false
	end

	for _, t in pairs(item.tags) do
		if(t == tag) then
			return true
		end
	end

	return false
end

local tagInfos =
{
	{
		displayName = "GregTech Ingots",
		amount = 256,
		batchSize = 16,
		workers = 2,
		validationFunc = function(item)
			return hasTag(item, "minecraft:item/forge:ingots") and string.match(item.name, "^gtceu:")
		end,
		crafting = {},
		queued = {}
	}
}

mMon.setMonitor(monitor)
monitor.setTextScale(0.5)



local function getDataBlob()
	local craftableItems = bridge.listCraftableItems()

	local ret = {}
	for _, item in pairs(craftableItems) do
		for i, tagInfo in pairs(tagInfos) do
			if (tagInfo.validationFunc(item)) then
				if (not ret[i]) then
					ret[i] = {}
				end

				table.insert(ret[i], { 
					name = item.name,
					displayName = item.displayName,
					-- amount = item.amount,
					status = "Queued"
				})
			end
		end
	end

	return ret
end

local tabData = { 2, 30, 5, 10 }
local function render(dataBlob)
	monitor.clear()
	monitor.setCursorPos(1, 1)

	for i, itemRequests in pairs(dataBlob) do
		local tagInfo = tagInfos[i]

		mMon.writeLine(string.format("%s (Total: %d, Crafting: %d, Queued: %d)", tagInfo.displayName, #itemRequests, #tagInfo.crafting, #tagInfo.queued))
		
		for _, itemRequest in pairs(tagInfo.crafting) do
			mMon.writeTabbedLine(tabData, "", itemRequest.displayName, itemRequest.existingAmount, tagInfo.amount)
		end

		mMon.newLine()
	end
end

local function updateSingleStatus(itemRequest, tagInfo)
	local searchTbl = {name = itemRequest.name}

	itemRequest.existingAmount = 0
	local existingItem = bridge.getItem(searchTbl)
	if(existingItem) then
		itemRequest.existingAmount = existingItem.amount
	end

	if(itemRequest.existingAmount > tagInfo.amount) then
		itemRequest.status = "Ok"
		return
	end

	if(bridge.isItemCrafting(searchTbl)) then
		itemRequest.status = "Crafting"
		table.insert(tagInfo.crafting, itemRequest)
		return
	end

	itemRequest.status = "Queued"
	table.insert(tagInfo.queued, itemRequest)
end

local function startCrafting(queued, numCraftsToStart, tagInfo)
	local i = 0
	for _, itemRequest in pairs(queued) do
		local toCraft = math.min(tagInfo.batchSize, tagInfo.amount - itemRequest.existingAmount)
		bridge.craftItem({ name = itemRequest.name, count = toCraft})

		i = i + 1
		if(i >= numCraftsToStart) then
			return
		end
	end
end

local function updateStatus(dataBlob)
	for i, itemRequests in pairs(dataBlob) do
		local tagInfo = tagInfos[i]

		tagInfo.crafting = {}
		tagInfo.queued = {}

		for _, itemRequest in pairs(itemRequests) do
			updateSingleStatus(itemRequest, tagInfo)
		end

		local numCraftsToStart = tagInfo.workers - #tagInfo.crafting
		if(numCraftsToStart > 0) then
			table.sort(tagInfo.queued, function (a, b)
				return a.existingAmount < b.existingAmount
			end)

			startCrafting(tagInfo.queued, numCraftsToStart, tagInfo)
		end
	end
end

local dataBlob = getDataBlob()

while (true) do
	updateStatus(dataBlob)
	render(dataBlob)
	os.sleep(5)
end

