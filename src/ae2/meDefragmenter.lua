--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meDefragmenter.lua

package.path = package.path .. ";../core/?.lua"

local jGui = require("jGui")

local monitor = peripheral.find("monitor")
local mWidth, mHeight = monitor.getSize()

local bulkStorages = { peripheral.find("dankstorage:dank_tile") }
local bulkStorageI = 1

local nbtStorages = { peripheral.find("entangled:tile") }
local nbtStorageI = 1
local nbtStorageLimit = 1024

monitor.clear()

local unstackableItems = {
	["minecraft:bundle"] = true
}

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

local function setTextLine(text, line)
	monitor.setCursorPos(1, line)
	monitor.clearLine()
	jGui.writeCenter(text)
end

jGui.setMonitor(monitor)

setTextLine("Bulk Storage", 1)
setTextLine("NBT Storage", 6)

local created = false
while (true) do
	setTextLine("Defragmenting", 11)
	setTextLine("Bulk Storage", 12)
	local bulkOcc, bulkTot = defragmentStorages(bulkStorages)

	setTextLine("Moving items to", 11)
	setTextLine("NBT Storage", 12)
	moveToNbt()

	setTextLine("Defragmenting", 11)
	setTextLine("NBT Storage", 12)
	local nbtOcc, nbtTot = defragmentStorages(nbtStorages)

	setTextLine("Moving items to", 11)
	setTextLine("Bulk Storage", 12)
	moveToBulk()

	if (not created) then
		jGui.createSlider("bulkSlider", bulkTot, 2, 2, mWidth - 2, 3, colors.red, colors.lime, jGui.Numbers)
		jGui.createSlider("nbtSlider", nbtTot, 2, 7, mWidth - 2, 3, colors.red, colors.lime, jGui.Numbers)
		created = true
	end

	jGui.updateSlider("bulkSlider", bulkOcc)
	jGui.updateSlider("nbtSlider", nbtOcc)
	jGui.draw()

	os.sleep(5)
end
