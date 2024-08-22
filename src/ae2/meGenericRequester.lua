--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meGenericRequester.lua

package.path = package.path .. ";../core/?.lua"

local dump = require("dump")
local mItem = require("moreItem")
local aeNameUtil = require("libs.aeNameUtil")

local bridge = peripheral.find("meBridge")
local monitor = peripheral.find("monitor")

local tag = "minecraft:item/forge:ingots"

local craftableItems = bridge.listCraftableItems()

local testItem = nil
for _, item in pairs(craftableItems) do
	if(item.name == "gtceu:hsss_ingot") then
		testItem = item
	end
end

dump.easy(testItem.tags)
print(testItem.tags["minecraft:item/forge:ingots"])




