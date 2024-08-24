--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meGenericRequester.lua

package.path = package.path .. ";../core/?.lua"

local mMon = require("moreMonitor")
local mTable = require("moreTable")

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
		displayName = "G. Ingots",
		amount = 256,
		batchSize = 16,
		workers = 2,
		validationFunc = function(item)
			return hasTag(item, "minecraft:item/forge:ingots") and string.match(item.name, "^gtceu:")
		end,
		crafting = {},
		queued = {}
	},
	{
		displayName = "G. Motors",
		amount = 50,
		batchSize = 1,
		workers = 2,
		validationFunc = function(item)
			return string.match(item.name, "^gtceu:") and string.match(item.name, "electric_motor$")
		end,
		crafting = {},
		queued = {}
	},
	{
		displayName = "G. Machine Hull",
		amount = 50,
		batchSize = 1,
		workers = 2,
		validationFunc = function(item)
			return string.match(item.name, "^gtceu:") and string.match(item.name, "machine_hull$")
		end,
		crafting = {},
		queued = {}
	},
	{
		displayName = "G. Processors",
		amount = 50,
		batchSize = 1,
		workers = 1,
		validationFunc = function(item)
			return string.match(item.name, "^gtceu:nano_processor")
		end,
		crafting = {},
		queued = {}
	}
}

mMon.setMonitor(monitor)
monitor.setTextScale(0.5)



local function getDataBlob()
	local craftableItems = bridge.listCraftableItems()

	if(not craftableItems) then
		craftableItems = bridge.listCraftableItems()
	end

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
					status = "Queued"
				})
			end
		end
	end

	return ret
end

local tabData = { 2, 30, 5, 10, 10 }
local colorTable = {
	["Ok"] = colors.green,
	["Crafting"] = colors.yellow,
	["Queued"] = colors.orange,
	["Error"] = colors.red,
}

local function render(dataBlob)
	monitor.clear()
	monitor.setCursorPos(1, 1)

	for i, itemRequests in pairs(dataBlob) do
		local tagInfo = tagInfos[i]

		local total = #itemRequests
		local totalSum = total * tagInfo.amount
		local crafting =#tagInfo.crafting
		local queued = #tagInfo.queued
		local complete = ((totalSum- tagInfo.missingItems) / totalSum) * 100

		local writeColor = colorTable["Crafting"]
		if(#tagInfo.stuck > 0) then
			writeColor = colorTable["Error"]
		elseif(crafting == 0 and queued == 0) then
			writeColor = colorTable["Ok"]
		end


		mMon.writeLine(string.format("[%.2f%%] %s (Tot: %d, Craft: %d, Queue: %d)", complete, tagInfo.displayName, total, crafting, queued), writeColor)
		mMon.toggleColor()
		
		for _, itemRequest in pairs(tagInfo.crafting) do
			mMon.toggleColor(colorTable[itemRequest.status])
			mMon.writeTabbedLine(tabData, "", itemRequest.displayName, itemRequest.existingAmount, tagInfo.amount)
			mMon.toggleColor()
		end

		for _, itemRequest in pairs(tagInfo.stuck) do
			mMon.toggleColor(colorTable[itemRequest.status])
			mMon.writeTabbedLine(tabData, "", itemRequest.displayName, itemRequest.existingAmount, tagInfo.amount)
			mMon.toggleColor()
		end

		mMon.newLine()
	end
end

local function updateSingleStatus(itemRequest, tagInfo)
	local searchTbl = {name = itemRequest.name}

	local existingItem = bridge.getItem(searchTbl)
	if(existingItem) then
		if(existingItem.amount > (itemRequest.existingAmount or 0)) then
			itemRequest.startingTries = 0
		end

		itemRequest.existingAmount = existingItem.amount
	else
		itemRequest.existingAmount = 0
	end

	tagInfo.missingItems = (tagInfo.missingItems or 0) + math.max(tagInfo.amount - itemRequest.existingAmount, 0)

	if(itemRequest.existingAmount >= tagInfo.amount) then
		itemRequest.startingTries = 0
		itemRequest.status = "Ok"
		return
	end

	if(bridge.isItemCrafting(searchTbl)) then
		itemRequest.startingTries = 0
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

		itemRequest.startingTries = (itemRequest.startingTries or 0) + 1
		if(itemRequest.startingTries > 5 and itemRequest.startingTries % 5 ~= 0) then
			itemRequest.status = "Error"
			table.insert(tagInfo.stuck, itemRequest)
		else
			local success, err = bridge.craftItem({ name = itemRequest.name, count = toCraft})

			if(not success) then
				print(string.format("Error trying to start craft for: %s. Message: %s", itemRequest.name, err))
			else
				itemRequest.status = "Crafting"
				table.insert(tagInfo.crafting, itemRequest)
				mTable.removeAll(tagInfo.queued, function (r)
					return r.name == itemRequest.name
				end)
			end

			i = i + 1
			if(i >= numCraftsToStart) then
				return
			end
		end
	end
end

local function updateStatus(dataBlob)
	for i, itemRequests in pairs(dataBlob) do
		local tagInfo = tagInfos[i]

		tagInfo.missingItems = 0

		tagInfo.crafting = {}
		tagInfo.queued = {}
		tagInfo.stuck = {}

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
	os.sleep(2)
end

