--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meFluidDefragmenter.lua

package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")

local mTable = require("moreTable")
local mString = require("moreString")
local dump = require("dump")

local readers = { pWrapper.find("blockReader") }


local fluidLocations = {}


for _, reader in pairs(readers) do
	local blockData = reader.getBlockData()

	for diskNo, inv in pairs(blockData.inv) do
		if(inv.tag and inv.tag.keys) then
			for _, fluid in pairs(inv.tag.keys) do
				if(not fluidLocations[fluid.id]) then
					fluidLocations[fluid.id] = {}
				end
				table.insert(fluidLocations[fluid.id], { reader = reader.name, diskNo = diskNo})
			end
		end
	end
end

for fluid, locations in pairs(fluidLocations) do
	if(#locations > 1) then
		print(fluid .. " exists: ")
		for _, location in pairs(locations) do
			print("\t" .. location.name .. " => " .. location.diskNo)
		end
	end
end


