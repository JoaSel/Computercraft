--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meTagRequester.lua

package.path = package.path .. ";../core/?.lua"

local dump = require("dump")
local aeNameUtil = require("libs.aeNameUtil")

local bridge = peripheral.find("meBridge")
local monitor = peripheral.find("monitor")
local tagData =
{
	["minecraft:item/forge:ingots"] =
	{
		amount = 256,
		batch = 16,
		workers = 1,
		validationFunc = function(item)
			return string.match(item.name, "^gtceu:")
		end
	}
}

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
		for tag, tagInfo in pairs(tagData) do
			if (hasTag(item, tag) and tagInfo.validationFunc(item)) then
				if (not ret[tag]) then
					ret[tag] = {}
				end

				table.insert(ret[tag], item.name)
			end
		end
	end

	return ret
end

local requestData = getRequestData()

dump.easy(requestData)


