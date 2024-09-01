--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/logistics/beeSorter.lua
local circularSorter = require("libs.circularSorter")

local dimChests = { peripheral.find("dimstorage:dimensional_chest") }

local input = nil
local inputName = "dimstorage:dimensional_chest_24"

local internalBuffer = nil
local internalBufferName = "dimstorage:dimensional_chest_8"

local destinationNames = {
	["Centrifuge Input"] = "dimstorage:dimensional_chest_9",
	["Storage Input"] = "dimstorage:dimensional_chest_23",
	["Centrifuge Fluid Input"] = "dimstorage:dimensional_chest_11",
	["Furnace Input"] = "dimstorage:dimensional_chest_12",
	["Compactor Input"] = "dimstorage:dimensional_chest_13",
	["Nugget Input"] = "dimstorage:dimensional_chest_21",
}

local displayNamesRoutes = {
	["Oily Comb Block"] = "Centrifuge Fluid Input",
	["Energized Glowstone Comb Block"] = "Centrifuge Fluid Input",
	["Wasted Radioactive Comb Block"] = "Storage Input",
	["Raw Neodymium"] = "Storage Input",
	["Raw Palladium"] = "Storage Input",
	["Raw Sheldonite"] = "Storage Input",
	["Raw Naquadah"] = "Storage Input",
	["Hydrogen"] = "Storage Input",
	["Oxygen"] = "Storage Input"
}

local tagsRoutes = {
	["forge:storage_blocks/honeycombs"] = "Centrifuge Input",
	["forge:raw_materials"] = "Furnace Input",
	["forge:nuggets"] = "Nugget Input"
}

local miscRoutes = {
	function(item)
		if (string.match(item.name, "^chemlib")) then
			return "Compactor Input"
		end
	end
}


for i = 1, #dimChests do
	if (peripheral.getName(dimChests[i]) == inputName) then
		print("Initialized " .. inputName .. " as input.")
		input = dimChests[i]
	end
	if (peripheral.getName(dimChests[i]) == internalBufferName) then
		print("Initialized " .. internalBufferName .. " as internal buffer.")
		internalBuffer = dimChests[i]
	end
end

circularSorter.create(input, internalBuffer, "Storage Input", destinationNames, displayNamesRoutes, tagsRoutes, miscRoutes)
circularSorter.run()