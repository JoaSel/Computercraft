--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meMultiBlockRequester.lua

package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")
local dump = require("dump")

local chest = pWrapper.find("minecraft:chest")
local nbtStorage = pWrapper.find("blockReader")

for prop, test in pairs(nbtStorage.getBlockData()) do
	print(prop)
	print(test)
end

