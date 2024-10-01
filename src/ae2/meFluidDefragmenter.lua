--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meFluidDefragmenter.lua

package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")

local mTable = require("moreTable")
local mString = require("moreString")
local dump = require("dump")

local readers = { pWrapper.find("blockReader") }


local blockData = readers[1].getBlockData()

print(readers[1].name)

for _, reader in pairs(readers) do
	
end


