--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meGenericRequester.lua

package.path = package.path .. ";../core/?.lua"

local dump = require("dump")
local mMon = require("moreMonitor")
local mTable = require("moreTable")
local jGui = require("jGui")

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
		displayName = "Greg Ingots",
		amount = 256,
		batchSize = 16,
		workers = 2,
		validationFunc = function(item)
			return hasTag(item, "minecraft:item/forge:ingots") and string.match(item.name, "^gtceu:")
		end
	},
	{
		displayName = "Greg Components",
		amount = 50,
		batchSize = 1,
		workers = 2,
		validationFunc = function(item)
			return
				(string.match(item.name, "^gtceu:") and (
					string.match(item.name, "electric_motor$") or
					string.match(item.name, "robot_arm$")))
		end
	},
	{
		displayName = "Greg Machine Hull",
		amount = 50,
		batchSize = 1,
		workers = 2,
		validationFunc = function(item)
			return string.match(item.name, "^gtceu:") and string.match(item.name, "machine_hull$")
		end
	},
	{
		displayName = "Greg Chips",
		amount = 50,
		batchSize = 1,
		workers = 1,
		validationFunc = function(item)
			return string.match(item.name, "^gtceu:(.*)processor")
		end
	}
}

monitor.clear()
monitor.setTextScale(0.5)
mMon.setMonitor(monitor)
jGui.setMonitor(monitor)


local function getDataBlob()
	local craftableItems = bridge.listCraftableItems()

	if(not craftableItems) then
		return nil
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
		table.insert(tagInfo.ok, itemRequest)
		return
	end

	if(bridge.isItemCrafting(searchTbl)) then
		itemRequest.startingTries = 0
		itemRequest.status = "Crafting"
		table.insert(tagInfo.crafting, itemRequest)
		return
	end

	if(itemRequest.startingTries > 5) then
		itemRequest.status = "Error"
		table.insert(tagInfo.stuck, itemRequest)
		return
	end

	itemRequest.status = "Queued"
	table.insert(tagInfo.queued, itemRequest)
end

local function startCraftingItem(itemRequest, tagInfo)
	local toCraft = math.min(tagInfo.batchSize, tagInfo.amount - itemRequest.existingAmount)

	itemRequest.startingTries = (itemRequest.startingTries or 0) + 1

	local success, err = bridge.craftItem({ name = itemRequest.name, count = toCraft})
	if(not success) then
		print(string.format("Error trying to start craft for: %s. Message: %s", itemRequest.name, err))
		return false
	end

	return true
end

local function startCrafting(queued, stuck, numCraftsToStart, tagInfo)
	local craftsStarted = 0

	for _, itemRequest in pairs(stuck) do
		if(itemRequest.startingTries % 5 == 0) then
			if(startCraftingItem(itemRequest, tagInfo)) then
				craftsStarted = craftsStarted + 1
			end
		end

		if(craftsStarted >= numCraftsToStart) then
			return
		end
	end

	for _, itemRequest in pairs(queued) do
		if(startCraftingItem(itemRequest, tagInfo)) then
			craftsStarted = craftsStarted + 1
		end

		if(craftsStarted >= numCraftsToStart) then
			return
		end
	end
end

local function updateStatus(dataBlob)
	for i, itemRequests in pairs(dataBlob) do
		local tagInfo = tagInfos[i]

		tagInfo.missingItems = 0

		tagInfo.ok = {}
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

			startCrafting(tagInfo.queued, tagInfo.stuck, numCraftsToStart, tagInfo)
		end
	end
end


local tabData = { 2, 30, 5, 10, 10 }
local colorTable = {
	["Ok"] = colors.green,
	["Crafting"] = colors.yellow,
	["Queued"] = colors.orange,
	["Error"] = colors.red,
}

local function renderDefault(dataBlob)
	for i, itemRequests in pairs(dataBlob) do
		local tagInfo = tagInfos[i]

		local total = #itemRequests
		local totalSum = total * tagInfo.amount
		local crafting =#tagInfo.crafting
		local queued = #tagInfo.queued
		local complete = ((totalSum- tagInfo.missingItems) / totalSum) * 100

		jGui.updateSliderMaxValue(tagInfo.displayName, totalSum)
		jGui.updateSliderValue(tagInfo.displayName, totalSum- tagInfo.missingItems)

		local writeColor = colorTable["Crafting"]
		if(#tagInfo.stuck > 0) then
			writeColor = colorTable["Error"]
		elseif(crafting == 0 and queued == 0) then
			writeColor = colorTable["Ok"]
		elseif (crafting == 0 and queued > 0) then
			writeColor = colorTable["Queued"]
		end

		mMon.writeCenter(
		string.format("%s (Tot: %d, Craft: %d, Queue: %d)", tagInfo.displayName, total, crafting,
			queued), writeColor)
		mMon.toggleColor()
		jGui.drawSlider(tagInfo.displayName, 3)

		mMon.newLine()
	end
end

local function renderTag(tagIndex)
	local tagInfo = tagInfos[tagIndex]

	jGui.writeClickableText("HomeBtn", "right")
	mMon.writeCenter(tagInfo.displayName)
	mMon.newLine()

	local sortFunc = function (a, b)
		return a.displayName > b.displayName
	end

	table.sort(tagInfo.stuck, sortFunc);
	table.sort(tagInfo.crafting, sortFunc);
	table.sort(tagInfo.queued, sortFunc);
	table.sort(tagInfo.ok, sortFunc);

	for _, itemRequest in pairs(tagInfo.stuck) do
		mMon.toggleColor(colorTable[itemRequest.status])
		mMon.writeTabbedLine(tabData, "", itemRequest.displayName, itemRequest.existingAmount, tagInfo.amount)
		mMon.toggleColor()
	end
	for _, itemRequest in pairs(tagInfo.crafting) do
		mMon.toggleColor(colorTable[itemRequest.status])
		mMon.writeTabbedLine(tabData, "", itemRequest.displayName, itemRequest.existingAmount, tagInfo.amount)
		mMon.toggleColor()
	end
	for _, itemRequest in pairs(tagInfo.queued) do
		mMon.toggleColor(colorTable[itemRequest.status])
		mMon.writeTabbedLine(tabData, "", itemRequest.displayName, itemRequest.existingAmount, tagInfo.amount)
		mMon.toggleColor()
	end
	for _, itemRequest in pairs(tagInfo.ok) do
		mMon.toggleColor(colorTable[itemRequest.status])
		mMon.writeTabbedLine(tabData, "", itemRequest.displayName, itemRequest.existingAmount, tagInfo.amount)
		mMon.toggleColor()
	end
end

local renderPage = 0
local function render(dataBlob)
	jGui.reset();

	if(renderPage == 0) then
		renderDefault(dataBlob)
	else
		renderTag(renderPage)
	end
end



local dataBlob = nil

repeat
	dataBlob = getDataBlob()
	if(not dataBlob) then
		os.sleep(5)
	end
until dataBlob

for tagIndex, tagInfo in pairs(tagInfos) do
	jGui.createSlider(tagInfo.displayName, 100, -2, 2, colors.lime, colors.red, "Percent", function ()
		renderPage = tagIndex
		render(dataBlob)
	end)
end

jGui.createClickableText("HomeBtn", "X", function ()
	renderPage = 0
	render(dataBlob)
end)


parallel.waitForAny(
	function()
		while (true) do
			updateStatus(dataBlob)
			render(dataBlob)
			os.sleep(2)
		end
	end,
	function()
		while true do
			local _, _, x, y = os.pullEvent("monitor_touch")
			jGui.click(x, y)
		end
	end
)

