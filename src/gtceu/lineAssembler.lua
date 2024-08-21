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

    local test = next(inputBuses)

    dump.printDump(test)

    -- for fromSlot, item in pairs(inputItems) do
    --     for _, inputBus in pairs(inputBuses) do
    --         for i = 1, inputBus.size() do
    --             print("Importing " .. item.name)
    --             input.pushItems(inputBus.name, fromSlot, 64, i)
    --         end
    --     end
    -- end
end

local function importFluids()
    local inputFluids = input.tanks()

    for _, item in pairs(inputFluids) do
        print("Importing " .. item.name)
        for _, inputHatch in pairs(inputHatches) do
            input.pushFluid(inputHatch.name)
        end
    end
end

local function exportItems()
    for _, outputBus in pairs(outputBuses) do
        local outputItems = outputBus.list()

        for fromSlot, item in pairs(outputItems) do
            print("Exporting " .. item.name)
            outputBus.pushItems(output.name, fromSlot)
        end

        if(#outputBus.list() > 0) then
            error("Failed to export some items")
        end
    end
end


importItems()
--importFluids()

--exportItems()
--exportFluids()


