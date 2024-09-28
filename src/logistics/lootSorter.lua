--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/logistics/lootSorter.lua

package.path = package.path .. ";../core/?.lua"

local circularSorter = require("libs.circularSorter")
local pWrapper = require("peripheralWrapper")

local input = pWrapper.wrap("dankstorage:dank_tile_34")
local internalBuffer = pWrapper.wrap("dankstorage:dank_tile_35")

local saveStash = pWrapper.wrap("sophisticatedstorage:shulker_box_10")
local trashStash = pWrapper.wrap("sophisticatedstorage:shulker_box_11")

local curses = {
    ["minecraft:binding_curse"] = true,
    ["minecraft:vanishing_curse"] = true,
    ["evilcraft:breaking"] = true,
    ["evilcraft:vengeance"] = true,
    ["enderio:shimmer"] = true
}

local toolItems = {
    ["forbidden_arcanus:zombie_arm"] = true
}

local destinationNames = {
	["Storage Input"] = "sophisticatedstorage:chest_3",
	["Disenchant"] = "dimstorage:dimensional_chest_26",
	["Library"] = "dimstorage:dimensional_chest_27",
	["Salvage"] = "dimstorage:dimensional_chest_28",
	["Trash"] = "trashcans:item_trash_can_tile_2",
}

local displayNamesRoutes = {}

local tagsRoutes = {}

local miscRoutes = {
	function(item)
		if(string.match(item.name, "_salt_ore$")) then
			return "Storage Input"
		end
		if (string.match(item.name, "^gtceu:") and circularSorter.hasTag(item, "forge:ores")) then
			return "Macerator"
		end
		if (string.match(item.name, "^gtceu:") and circularSorter.hasTag(item, "forge:raw_materials")) then
			return "Macerator"
		end
	end
}


local function initializeRoutes(peripheral, destination)
    for _, item in pairs(peripheral.list()) do
        displayNamesRoutes[item.name] = destination
    end
end

initializeRoutes(saveStash, "Storage Input")
initializeRoutes(trashStash, "Trash")


circularSorter.create(input, internalBuffer, "Storage Input", destinationNames, displayNamesRoutes, tagsRoutes, miscRoutes)
circularSorter.run()



















