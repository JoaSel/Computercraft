--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/gtceu/lineAssembler.lua

package.path = package.path .. ";../core/?.lua"

local dump = require("dump")
local pWrapper = require("peripheralWrapper")
local ioUtil = require("ioUtil")

local machine = pWrapper.find("blockReader")

local input = pWrapper.wrap("entangled:tile_20")
local output = pWrapper.wrap("entangled:tile_21")

local dataAccessHatch = pWrapper.find("gtceu:data_access_hatch")

local inputBuses = { ioUtil.findInputBuses() }
local inputHatches = { pWrapper.find("gtceu:lv_input_hatch") }

table.sort(inputBuses, function (a, b)
    return a.name < b.name
end)
table.sort(inputHatches, function (a, b)
    return a.name < b.name
end)

local outputBuses = { pWrapper.find("gtceu:ulv_output_bus") }
local outputHatches = { pWrapper.find("gtceu:ulv_output_hatch") }

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

for _, inputBus in pairs(inputBuses) do
    print(inputBus.name)
end
--dump.printDump(pWrapper.find("gtceu:ulv_input_bus"))

--importItems()
--importFluids()

--exportItems()
-- exportFluids()


