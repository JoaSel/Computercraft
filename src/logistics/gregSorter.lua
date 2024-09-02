--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/logistics/gregSorter.lua
local circularSorter = require("libs.circularSorter")

local input = peripheral.find("dankstorage:dank_tile")
local internalBuffer = peripheral.find("entangled:tile")

local destinationNames = {
	["Macerator"] = "dimstorage:dimensional_chest_15",
	["Washer"] = "dimstorage:dimensional_chest_16",
	["Thermal Centrifuge"] = "dimstorage:dimensional_chest_17",
	["Storage Input"] = "dimstorage:dimensional_chest_20",
	["Centrifuge Input"] = "dimstorage:dimensional_chest_22"
}

local displayNamesRoutes = {
	["Crushed Rock Salt Ore"] = "Thermal Centrifuge",
	["Purified Pentlandite Ore"] = "Storage Input",
	["Purified Tetrahedrite Ore"] = "Storage Input",
	["Purified Chalcocite Ore"] = "Storage Input",
	["Purified Sheldonite Ore"] = "Storage Input",
	["Purified Bornite Ore"] = "Storage Input",
	["Purified Chalcopyrite Ore"] = "Storage Input",
	["Rare Earth Dust"] = "Centrifuge Input",
	["Raw Neodymium"] = "Storage Input",
	["Purified Sphalerite Ore"] = "Storage Input",
	["Purified Galena Ore"] = "Storage Input",
	["Granite Salt Ore"] = "Storage Input",
	["Red Granite Salt Ore"] = "Storage Input",
	["Tuff Salt Ore"] = "Storage Input"
}

local tagsRoutes = {
	["forge:crushed_ores"] = "Washer",
	["forge:purified_ores"] = "Thermal Centrifuge",
	["forge:refined_ores"] = "Macerator"
}

local miscRoutes = {
	function(item)
		if (string.match(item.name, "^gtceu:") and circularSorter.hasTag(item, "forge:ores")) then
			return "Macerator"
		end
		if (string.match(item.name, "^gtceu:") and circularSorter.hasTag(item, "forge:raw_materials")) then
			return "Macerator"
		end
	end
}


circularSorter.create(input, internalBuffer, "Storage Input", destinationNames, displayNamesRoutes, tagsRoutes, miscRoutes, true)
circularSorter.run()
