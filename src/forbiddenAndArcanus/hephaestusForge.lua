--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/forbiddenAndArcanus/hephaestusForge.lua

package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")
local mTerm = require("moreTerm")
local dump = require("dump")

local input = pWrapper.find("minecraft:chest")

local forgeGavel = pWrapper.wrap("modularrouters:modular_router_1")
local forgeReader = pWrapper.find("blockReader")

local forgeInput = pWrapper.find("forbidden_arcanus:hephaestus_forge")
local pedestal1 = pWrapper.wrap("modularrouters:modular_router_2")
local pedestal2 = pWrapper.wrap("modularrouters:modular_router_3")
local pedestal3 = pWrapper.wrap("modularrouters:modular_router_4")
local pedestal4 = pWrapper.wrap("modularrouters:modular_router_5")

print(forgeInput.name)

local function handleBloodLevels(blockData)
    print("Handling blood levels")
    if(blockData.Essences.Blood < 50000) then
        redstone.setOutput("bottom", true)
        return true
    end
    redstone.setOutput("bottom", false)
    return false
end

local function tick()
    local blockData = forgeReader.getBlockData()

    if(handleBloodLevels(blockData)) then
        return
    end
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