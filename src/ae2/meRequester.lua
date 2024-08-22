--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meRequester.lua

package.path = package.path .. ";../core/?.lua"

local file = require("file")
local net = require("net")
local aeNameUtil = require("libs.aeNameUtil")

local bridge = peripheral.find("meBridge")
local monitor = peripheral.find("monitor")
local playerDetector = peripheral.find("playerDetector")

local maxConcurrentJobs = 2
local playerName = "EvilKurt2"

local colorTable = {
	["Ok"] = colors.green,
	["Crafting"] = colors.yellow,
	["WorkerBusy"] = colors.orange,
	["PlayerOnline"] = colors.purple,
	["FailedToStart"] = colors.red,
}

monitor.setTextScale(0.5)

local function requestItem(itemName, requestInfo, existingItem)
	local craftCount = math.min(requestInfo.batch, requestInfo.amount - existingItem.amount)

	bridge.craftItem({ name = itemName, count = craftCount })

	local event, success, message = os.pullEvent("crafting")
	if success then
		requestInfo.status = "Crafting"
	else
		requestInfo.status = "FailedToStart"
	end
end

local function lineBreak()
	local _, y = monitor.getCursorPos()
	monitor.setCursorPos(1, y + 1)
end

local function writeTabbedLine(tabData, ...)
	local texts = { ... }
	local x, y
	local i = 1
	local currTab = 0
	for _, text in pairs(texts) do
		monitor.write(text)
		x, y = monitor.getCursorPos()
		currTab = currTab + tabData[i]
		monitor.setCursorPos(currTab, y)
		i = i + 1
	end
	monitor.setCursorPos(1, y + 1)
end

local tabData = { 30, 10, 10, 10 }
local function render(requestData)
	local workGroups = {}
	for _, requestInfo in pairs(requestData) do
		local workGroup = requestInfo.workGroup or "EmptyGroup"
		if (workGroups[workGroup] == nil) then
			workGroups[workGroup] = {}
		end
		table.insert(workGroups[workGroup], requestInfo)
	end

	monitor.clear()
	monitor.setCursorPos(1, 1)

	monitor.setTextColor(colors.white)
	writeTabbedLine(tabData, "Item", "Current", "Wanted", "Group")
	monitor.setCursorPos(1, 3)

	for _, workGroup in pairs(workGroups) do
		for _, requestInfo in pairs(workGroup) do
			monitor.setTextColor(colorTable[requestInfo.status])
			if (requestInfo.status ~= "FailedToStart") then
				writeTabbedLine(tabData, aeNameUtil.toDisplayName(requestInfo.existingItem.displayName),
					requestInfo.existingItem.amount, requestInfo.amount, requestInfo.workGroup)
			else
				writeTabbedLine(tabData, "ERROR: " .. requestInfo.message)
			end
		end
		lineBreak()
	end
end

local function updateRequestInfo(itemName, requestInfo, activeGroups, playerOnline)
	local searchItem = { name = itemName }

	local existingItem = bridge.getItem(searchItem)
	if (existingItem == nil or existingItem.amount == nil) then
		requestInfo.status = "FailedToStart"
		requestInfo.message = itemName
		return
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

local requestData = {}
local runCount = 0

while (true) do
	if (runCount % 100 == 0) then
		runCount = 0
		requestData = file.readAllAndParse("Computercraft/src/ae2/libs/meRequesterData.txt")
	end

	local activeGroups = {}
	activeGroups.currentJobs = 0
	local playerOnline = next(playerDetector.getPlayer(playerName)) ~= nil

	for itemName, requestInfo in pairs(requestData) do
		updateRequestInfo(itemName, requestInfo, activeGroups, playerOnline)
	end

	runCount = runCount + 1

	render(requestData)
	os.sleep(5)
end
