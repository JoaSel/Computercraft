--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/logistics/lootSorter.lua

package.path = package.path .. ";../core/?.lua"

local circularSorter = require("libs.circularSorter")
local pWrapper = require("peripheralWrapper")
local dump = require("dump")


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
    ["forbidden_arcanus:zombie_arm"] = true,
	["cataclysm:athame"] = true
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

local function isOnlyCursed(item)
    for _, enchantment in pairs(item.enchantments) do
        if(not curses[enchantment.name]) then
            return false
        end
    end
    return true
end

local function hasTag(item, tag)
    if(item.tags == nil) then
        return false
    elseif(item.tags[tag] == nil) then
        return false
    end
    return item.tags[tag]
end

local miscRoutes = {
	function(item)
		if (item.enchantments ~= nil) then
			if (item.name == "minecraft:enchanted_book") then
				return "Library"
			elseif (isOnlyCursed(item)) then
				return "Salvage"
			else
				return "Disenchant"
			end
		elseif (hasTag(item, "forge:tools") or
				hasTag(item, "forge:armors") or
				toolItems[item.name]
			) then
			return "Salvage"
		end
	end
}

local function initializeRoutes(peripheral, destination)
    for slot, item in pairs(peripheral.list()) do
		local info = peripheral.getItemDetail(slot)
        displayNamesRoutes[info.displayName] = destination
    end
end

initializeRoutes(saveStash, "Storage Input")
initializeRoutes(trashStash, "Trash")

circularSorter.create(input, internalBuffer, "Storage Input", destinationNames, displayNamesRoutes, tagsRoutes, miscRoutes)
circularSorter.run()



















