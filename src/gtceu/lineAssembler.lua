--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/gtceu/lineAssembler.lua

package.path = package.path .. ";../core/?.lua"

local dump = require("dump")

local machine = peripheral.find("blockReader")

local input = peripheral.wrap("entangled:tile_20")
local output = peripheral.wrap("entangled:tile_21")

local dataAccessHatch = peripheral.find("gtceu:data_access_hatch")

local inputBuses = { peripheral.find("gtceu:ulv_input_bus") }
local inputHatches = { peripheral.find("gtceu:lv_input_hatch") }

local outputBuses = { peripheral.find("gtceu:ulv_output_bus") }
local outputHatches = { peripheral.find("gtceu:ulv_output_hatch") }

local function isIdle()
    local data = machine.getBlockData()

    return data.recipeLogic.status == "IDLE"
end

local function addInputItems()
    local inputItems = input.list()

    for fromSlot, item in pairs(inputItems) do
        for _, inputBus in pairs(inputBuses) do
            for i = 1, inputBus.size() do
                input.pushItems(peripheral.getName(inputBus), fromSlot, 64, i)
            end
        end
    end
end

local function addInputFluids()
    local inputFluids = input.tanks()

    for _, item in pairs(inputFluids) do
        print("Adding " .. item.name)
        for _, inputHatch in pairs(inputHatches) do
            inputFluids.pushItems(peripheral.getName(inputHatch))
        end
    end
end

print(isIdle())
addInputItems()
addInputFluids()
