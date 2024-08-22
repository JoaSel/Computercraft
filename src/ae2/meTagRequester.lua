--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meTagRequester.lua

package.path = package.path .. ";../core/?.lua"

local dump = require("dump")
local aeNameUtil = require("libs.aeNameUtil")

local bridge = peripheral.find("meBridge")
local monitor = peripheral.find("monitor")

local tag = "minecraft:item/forge:ingots"


local craftableItems = bridge.listCraftableItems()

local function hasTag(item, tag)
	if(not item.tags) then
		return false
	end

	local ret = false;

	for t in item.tags do
		print(t)
	end

	return ret
end

local testItem = nil
for _, item in pairs(craftableItems) do
	if(item.name == "gtceu:hsss_ingot") then
		testItem = item
	end
end

hasTag(testItem, "")




