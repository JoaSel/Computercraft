--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meGenericRequester.lua

package.path = package.path .. ";../core/?.lua"

local dump = require("dump")
local mItem = require("moreItem")
local aeNameUtil = require("libs.aeNameUtil")

local bridge = peripheral.find("meBridge")
local monitor = peripheral.find("monitor")

local tag = "forge:ingots"

local craftableItems = bridge.listCraftableItems()
for _, item in pairs(craftableItems) do
	if(mItem.hasTag(item, tag)) then
    	print(item.name)
	end
end


dump.easy(craftableItems[1])


