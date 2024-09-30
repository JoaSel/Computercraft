--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meDefragmenter.lua true

package.path = package.path .. ";../core/?.lua"
package.path = package.path .. ";../../../?.lua"

local pWrapper = require("peripheralWrapper")

local basalt = require("basalt")
local mTable = require("moreTable")
local mString = require("moreString")
local dump = require("dump")

local monitor = pWrapper.find("monitor")

monitor.setTextScale(0.5)

local mainPage = {}

local unstackableItems = {
	["minecraft:bundle"] = true
}

local bulkStorages = { pWrapper.find("dankstorage:dank_tile") }
local bulkStorageI = 1

local nbtStorages = { pWrapper.find("entangled:tile") }
local nbtStorageI = 1
local nbtStorageLimit = 1024

local function indexItem(item, pName, collection)
	if (item.nbt == nil) then
		collection[item.name] = pName
	else
		collection[item.name .. item.nbt] = pName
	end
end

local function indexItemLoc(item, peripheral, slot, collection)
	local index = nil

	if (item.nbt == nil) then
		index = item.name
	else
		index = item.name .. item.nbt
	end

	if (not collection[index]) then
		collection[index] = {}
	end
	table.insert(collection[index], { count = item.count, peripheral = peripheral, slot = slot })
end

local function tryGet(item, collection)
	if (item.nbt == nil) then
		return collection[item.name]
	else
		return collection[item.name .. item.nbt]
	end
end

local function moveItems(fromPeripheral, toLoc, fromSlot, toMoveCount)
	local ret = 0
	repeat
		local moved = fromPeripheral.pushItems(toLoc, fromSlot)
		ret = ret + moved
	until (ret >= toMoveCount or moved == 0)
	return ret
end

local function defragmentStorages(storages)
	local allItems = {}
	local occupied = 0
	local total = 0

	for i = 1, #storages do
		local current = storages[i]
		local currentName = peripheral.getName(current)

		local currentItems = current.list()

		occupied = occupied + #currentItems
		total = total + current.size()

		for slot, item in pairs(currentItems) do
			if (not unstackableItems[item.name]) then
				local existingLoc = tryGet(item, allItems)
				if (existingLoc ~= nil) then
					print(item.count .. " " .. item.name .. " " .. currentName .. " => " .. existingLoc)
					moveItems(current, existingLoc, slot, item.count)
				else
					indexItem(item, currentName, allItems)
				end
			end
		end
	end
	return occupied, total
end

local function moveToNbt()
	for i = 1, #bulkStorages do
		local current = bulkStorages[i]
		local currentName = peripheral.getName(current)

		for slot, item in pairs(current.list()) do
			if (item.count < nbtStorageLimit) then
				print("Moving " .. item.name .. " to NBT Storage")
				moveItems(current, peripheral.getName(nbtStorages[nbtStorageI]), slot, item.count)
				nbtStorageI = (nbtStorageI % #nbtStorages) + 1
			end
		end
	end
end

local function moveToBulk()
	local allItems = {}
	for i = 1, #nbtStorages do
		local current = nbtStorages[i]
		local currentName = peripheral.getName(current)

		for slot, item in pairs(current.list()) do
			indexItemLoc(item, current, slot, allItems)
		end
	end

	for itemName, locations in pairs(allItems) do
		local sum = 0
		for i = 1, #locations do
			sum = sum + locations[i].count
		end
		if (sum > 1024) then
			for i = 1, #locations do
				print("Moving " .. itemName .. " to Bulk Storage")
				moveItems(locations[i].peripheral, peripheral.getName(bulkStorages[bulkStorageI]), locations[i].slot,
					locations[i].count)
			end
			bulkStorageI = (bulkStorageI % #bulkStorages) + 1
		end
	end
end

local base = basalt.addMonitor()
    :setForeground(colors.white)
    :setBackground(colors.black)
    :setMonitor(monitor)

mainPage.frame = base
    :addFrame()
    :setForeground(colors.white)
    :setBackground(colors.black)
    :setPosition(1, 1)
    :setSize("parent.w", "parent.h - 1")

mainPage.statusLabel = mainPage.frame
	:addLabel()
	:setText("Starting")
	:setTextAlign("center")
	:setSize("parent.w", 1)
	:setPosition(1, "parent.h - 1")

local function createCapacityBar(name, row)
	mainPage.frame
		:addLabel()
		:setText(name)
		:setTextAlign("center")
		:setSize("parent.w", 1)
		:setPosition(1, row)

	mainPage.frame
		:addProgressbar()
		:setDirection("right")
		:setProgress(50)
		:setProgressBar(colors.green)
		:setBackground(colors.red)
		:setPosition("parent.w * 0.125", row + 1)
		:setSize("parent.w * 0.75", 2)
		:setZIndex(1)

	mainPage.frame
		:addLabel()
		:setText(" 50%")
		:setPosition("(parent.w / 2) - 1", row + 2)
		:setZIndex(2)
		:setForeground(colors.black)
		:setTextAlign("center")
end

createCapacityBar("Bulk Item Storage", 1);
createCapacityBar("NBT Item Storage", 5);

local function defrag()
	while true do
		mainPage.statusLabel:setText("Defragmenting Bulk Items")
		local bulkOcc, bulkTot = defragmentStorages(bulkStorages)
		moveToNbt()

		mainPage.statusLabel:setText("Defragmenting NBT Items")
		local nbtOcc, nbtTot = defragmentStorages(nbtStorages)
		moveToBulk()

		mainPage.statusLabel:setText("Sleeping")
		os.sleep(5)
	end
	
end

base:addThread():start(defrag)

basalt.autoUpdate();