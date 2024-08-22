--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meTagRequester.lua

package.path = package.path .. ";../core/?.lua"

local dump = require("dump")
local mMon = require("moreMonitor")
local aeNameUtil = require("libs.aeNameUtil")

local bridge = peripheral.find("meBridge")
local monitor = peripheral.find("monitor")

local tagInfos =
{
	["minecraft:item/forge:ingots"] =
	{
		displayName = "Ingots",
		amount = 256,
		batch = 16,
		workers = 2,
		validationFunc = function(item)
			return string.match(item.name, "^gtceu:moly")
		end,
		queued = 0
	}
}

mMon.setMonitor(monitor)
monitor.setTextScale(0.5)

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

local function getDataBlob()
	local craftableItems = bridge.listCraftableItems()

	local ret = {}
	for _, item in pairs(craftableItems) do
		for tag, tagInfo in pairs(tagInfos) do
			if (hasTag(item, tag) and item.amount < tagInfo.amount and tagInfo.validationFunc(item)) then
				if (not ret[tag]) then
					ret[tag] = {}
				end

				table.insert(ret[tag], { 
					name = item.name,
					displayName = item.displayName,
					amount = item.amount,
					status = "Queued"
				})
			end
		end
	end

	return ret
end

local tabData = { 5, 30, 10, 10, 10 }
local function render(dataBlob)
	monitor.clear()
	monitor.setCursorPos(1, 1)

	for tag, itemRequests in pairs(dataBlob) do
		local tagInfo = tagInfos[tag]
		mMon.writeLine(tagInfo.displayName)
		
		for _, itemRequest in pairs(itemRequests) do
			mMon.writeTabbedLine(tabData, "", itemRequest.displayName, itemRequest.amount, tagInfo.amount, tagInfo.displayName)
		end
	end
end

local function handle(dataBlob)
	for tag, itemRequests in pairs(dataBlob) do
		local tagInfo = tagInfos[tag]

		local simultaneousJobs = 0
		for _, itemRequest in pairs(itemRequests) do
			if(bridge.isItemCrafting({name = itemRequest.name})) then
				simultaneousJobs = simultaneousJobs + 1
			end
			itemRequest.status = "Crafting"
		end
	end
end

local function updateRequestInfo(itemName, requestInfo, activeGroups, playerOnline)
	local searchItem = { name = itemName }

	local existingItem = bridge.getItem(searchItem)
	if (existingItem == nil or existingItem.amount == nil) then
		existingItem = {
			amount = 0,
			name = itemName,
			displayName = itemName
		}
	end

	requestInfo.existingItem = existingItem
	if (existingItem.amount >= requestInfo.amount) then
		requestInfo.status = "Ok"
		return
	end

	if (requestInfo.offlineOnly and playerOnline) then
		requestInfo.status = "PlayerOnline"
		return
	end

	if (activeGroups.currentJobs >= maxConcurrentJobs) then
		requestInfo.status = "WorkerBusy"
		return
	end

	local isItemCrafing = bridge.isItemCrafting(searchItem)
	if (isItemCrafing) then
		requestInfo.status = "Crafting"
		activeGroups.currentJobs = activeGroups.currentJobs + 1
		if (requestInfo.workGroup) then
			activeGroups[requestInfo.workGroup] = true
		end
		return
	end

	local groupRequest = requestInfo.workGroup ~= nil and activeGroups[requestInfo.workGroup]
	if (groupRequest) then
		requestInfo.status = "WorkerBusy"
		return
	end

	activeGroups.currentJobs = activeGroups.currentJobs + 1
	if (requestInfo.workGroup) then
		activeGroups[requestInfo.workGroup] = true
	end

	requestItem(itemName, requestInfo, existingItem)
end

local dataBlob = getDataBlob()
handle(dataBlob)
render(dataBlob)
