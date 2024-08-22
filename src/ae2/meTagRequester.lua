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
		displayName = "GregTech Ingots",
		amount = 256,
		batch = 16,
		workers = 2,
		validationFunc = function(item)
			return string.match(item.name, "^gtceu:hs")
		end,
		crafting = 0,
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
			if (hasTag(item, tag) and tagInfo.validationFunc(item)) then
				if (not ret[tag]) then
					ret[tag] = {}
				end

				table.insert(ret[tag], { 
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

	for tag, itemRequests in pairs(dataBlob) do
		local tagInfo = tagInfos[tag]

		mMon.writeLine(string.format("%s (Total: %d, Crafting: %d, Queued: %d)", tagInfo.displayName, #itemRequests, tagInfo.crafting, tagInfo.queued))
		
		for _, itemRequest in pairs(itemRequests) do
			mMon.writeTabbedLine(tabData, "", itemRequest.displayName, itemRequest.existingAmount, tagInfo.amount)
		end
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
		tagInfo.crafting = tagInfo.crafting + 1
		return
	end

	itemRequest.status = "Queued"
	tagInfo.queued = tagInfo.queued + 1
end

local function updateStatus(dataBlob)
	for tag, itemRequests in pairs(dataBlob) do
		local tagInfo = tagInfos[tag]

		tagInfo.crafting = 0
		tagInfo.queued = 0

		for _, itemRequest in pairs(itemRequests) do
			updateSingleStatus(itemRequest, tagInfo)
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
updateStatus(dataBlob)
render(dataBlob)
