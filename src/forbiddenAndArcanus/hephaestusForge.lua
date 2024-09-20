--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/forbiddenAndArcanus/hephaestusForge.lua

package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")
local mTerm = require("moreTerm")
local dump = require("dump")

local outputList = {
    ["forbidden_arcanus:eternal_stella"] = true
}

local input = pWrapper.wrap("minecraft:chest_6")
local output = pWrapper.wrap("minecraft:chest_7")

local gavelRouter = pWrapper.wrap("modularrouters:modular_router_1")
local gavelRedstone = pWrapper.find("redstoneIntegrator")
local forgeReader = pWrapper.find("blockReader")

local inputDestinations = {
    pWrapper.find("forbidden_arcanus:hephaestus_forge"),
    pWrapper.wrap("modularrouters:modular_router_2"),
    pWrapper.wrap("modularrouters:modular_router_3"),
    pWrapper.wrap("modularrouters:modular_router_4"),
    pWrapper.wrap("modularrouters:modular_router_5")
}

local forgeInput = inputDestinations[1]

local function handleBlood(blockData)
    print("Handling blood: " .. blockData.Essences.blood)


    if(blockData.Essences.blood < 50000) then
        redstone.setOutput("bottom", true)
        return true
    end

    redstone.setOutput("bottom", false)
    return false
end

local function handleInput(blockData)
    if(next(blockData.Ritual)) then
        print("Doing ritual, waiting: " .. blockData.Ritual.ActiveRitual)
        return true
    end

    local items = input.list()
    if(not next(items)) then
        return false
    end

    if(#items > 4) then
        error("Too many items in input.")
    end

    local destinationSlot = 1
    for slot, item in pairs(items) do
        for i = 1, item.count, 1 do
            input.pushItems(inputDestinations[destinationSlot].name, slot, 1)
            destinationSlot = destinationSlot + 1
        end
    end
end

local function handleOutput(blockData)
    local items = forgeInput.list()

    local middleItem = items[5]

    if (not middleItem) then
        return false
    end

    if(outputList[middleItem.name]) then
        forgeInput.pushItems(output.name, 5)
        return false
    end

    os.sleep(5)
    gavelRedstone.setOutput("east", true)
    os.sleep(1)
    gavelRedstone.setOutput("east", false)
end
local function tick()
    local blockData = forgeReader.getBlockData()

    if(handleBlood(blockData)) then
        return
    end

    if(handleOutput(blockData)) then
        return
    end

    if(handleInput(blockData)) then
        return
    end

    print("Tick End")
end

while (true) do
    tick()
    os.sleep(2)
end

-- {
--     Inventory = {
--       Items = {
--         {
--           id = "minecraft:diamond",
--           Count = 1,
--           Slot = 4,
--         },
--       },
--       Size = 9,
--     },
--     Ritual = {
--       ActiveRitual = "ResourceKey[forbidden_arcanus:hephaestus_forge/ritual / forbidden_arcanus:eternal_stella]",
--       Counter = 37,
--     },
--     Essences = {
--       souls = 33,
--       aureal = 19918,
--       experience = 432,
--       blood = 73580,
--     },
--     ForgeCaps = {},
--   }