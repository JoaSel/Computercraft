--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meMultiBlockRequester.lua

package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")
local dump = require("dump")

local chest = pWrapper.find("minecraft:chest")
local nbtStorage = pWrapper.find("blockReader")

local blockData = nbtStorage.getBlockData()

local items = blockData.Items[1].tag["in"]

for prop, test in pairs(items) do
	print(prop)
	dump.easy(test)
end



