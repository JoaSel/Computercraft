--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meFluidDefragmenter.lua

package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")

local mTable = require("moreTable")
local mString = require("moreString")
local dump = require("dump")

local readers = { pWrapper.find("blockReader") }





for _, reader in pairs(readers) do
	local blockData = reader.getBlockData()

	for diskNo, inv in pairs(blockData.inv) do
		if(inv.tag and inv.tag.keys) then
			for _, value in pairs(inv.tag.keys) do
				print(diskNo .. " " .. value.id)
			end
		end
	end
end


