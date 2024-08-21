--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/gtceu/lineAssembler.lua

package.path = package.path .. ";../core/?.lua"

local dump = require("dump")
local pWrapper = require("peripheralWrapper")
local ioUtil = require("libs.ioUtil")

local machine = pWrapper.find("blockReader")

local input = pWrapper.wrap("entangled:tile_20")
local output = pWrapper.wrap("entangled:tile_21")

local dataAccessHatch = pWrapper.find("gtceu:data_access_hatch")

local inputBuses = { ioUtil.findInputBuses() }
local inputHatches = { ioUtil.findInputHatches() }

local outputBuses = { ioUtil.findOutputBuses() }
local outputHatches = { ioUtil.findOutputHatches() }

local function isIdle()
    local data = machine.getBlockData()

    return data.recipeLogic.status == "IDLE"
end

local function importItems()
    local inputItems = input.list()

    for fromSlot, item in pairs(inputItems) do
        for _, inputBus in pairs(inputBuses) do
            for i = 1, inputBus.size() do
                print("Adding " .. item.name)
                input.pushItems(inputBus.name, fromSlot, 64, i)
            end
        end
    end
end

local function importFluids()
    local inputFluids = input.tanks()

    for _, item in pairs(inputFluids) do
        print("Adding " .. item.name)
        for _, inputHatch in pairs(inputHatches) do
            input.pushFluid(inputHatch.name)
        end
    end
end

local function exportItems()
    for _, outputBus in pairs(outputBuses) do
        local outputItems = outputBus.list()

        for fromSlot, item in pairs(outputItems) do
            outputBus.pushItems(output.name, fromSlot)
        end

        print("test")
        print(outputBus.list())
    end
end

for _, inputBus in pairs(outputBuses) do
    print(inputBus.name)
end
--dump.printDump(pWrapper.find("gtceu:ulv_input_bus"))

--importItems()
--importFluids()

--exportItems()
-- exportFluids()


