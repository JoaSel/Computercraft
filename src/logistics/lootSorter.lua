local input = peripheral.find("entangled:tile")
local trash = peripheral.find("trashcans:item_trash_can_tile")

local dimChests = { peripheral.find("dimstorage:dimensional_chest") }
local disenchant = dimChests[1]
local mainStorage = dimChests[2]
local salvage = dimChests[3]
local library = dimChests[4]

local shulkerBoxes = { peripheral.find("sophisticatedstorage:shulker_box") }
local trashStage = shulkerBoxes[1]
local trashStash = shulkerBoxes[2]
local saveStash = shulkerBoxes[3]

local USETRASHSTAGE = false
local trashStageI = 1

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

local function moveItems(fromPeripheral, toLoc, fromSlot, toMoveCount) 
    local ret = 0
    repeat
        local moved = fromPeripheral.pushItems(toLoc, fromSlot)
        ret = ret + moved
    until (ret >= toMoveCount or moved == 0)
    return ret
end

local function assignItems(peripheral)
	local ret = {}
	for _, item in pairs(peripheral.list()) do
  		ret[item.name] = true
	end
	return ret
end


local saveNames = assignItems(saveStash)
local trashNames = assignItems(trashStash)

local function hasValue (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

local function hasTag(item, tag)
	if(item.tags == nil) then
		return false
	elseif(item.tags[tag] == nil) then
		return false
	end
	return item.tags[tag]
end

local function trashItem(i, itemCount)
	if(USETRASHSTAGE) then
		trashStage.pushItems(peripheral.getName(trash), trashStageI)
		trashStageI = (trashStageI % 132) + 1
		input.pushItems(peripheral.getName(trashStage), i)
	else
		moveItems(input, peripheral.getName(trash), i, itemCount) 
	end
end

local function isOnlyCursed(item)
	for _, enchantment in pairs(item.enchantments) do
  		if(not curses[enchantment.name]) then
			return false
		end
	end
	return true
end

local function handleItem(item, i)
	if(item.enchantments ~= nil) then
		if(item.name == "minecraft:enchanted_book") then
			input.pushItems(peripheral.getName(library), i)
		elseif(isOnlyCursed(item)) then
			input.pushItems(peripheral.getName(salvage), i)
		else			
			input.pushItems(peripheral.getName(disenchant), i)
		end
	elseif(hasTag(item, "forge:tools") or 
           hasTag(item, "forge:armors") or
           toolItems[item.name]
        ) then
		input.pushItems(peripheral.getName(salvage), i)
	elseif(trashNames[item.name]) then
		trashItem(i, item.count)
	elseif(saveNames[item.name]) then
		moveItems(input, peripheral.getName(mainStorage), i, item.count) 
	elseif(hasTag(item, "travelersbackpack:custom_travelers_backpack")) then
		input.pushItems(peripheral.getName(mainStorage), i)
	end
end

while(true) do
	for i=1,input.size() do 
		local item = input.getItemDetail(i)
		if(item ~= nil) then
			handleItem(item, i)
		elseif(i == 1) then
			os.sleep(5)
		end
	end
end

























