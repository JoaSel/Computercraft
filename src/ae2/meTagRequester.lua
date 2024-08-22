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
		workers = 1,
		validationFunc = function(item)
			return string.match(item.name, "^gtceu:moly")
		end
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

local function getRequestData()
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
					amount = item.amount
				})
			end
		end
	end

	return ret
end

local function render(requestData)
	monitor.clear()
	monitor.setCursorPos(1, 1)

	for tag, data in pairs(requestData) do
		local tagInfo = tagInfos[tag]
		mMon.writeLine(tagInfo.displayName)

		for k, v in pairs(data) do
			dump.easy(v)
		end
	end
end

local requestData = getRequestData()
render(requestData)

dump.easy(requestData)


