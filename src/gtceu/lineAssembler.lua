--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/gtceu/lineAssembler.lua

package.path = package.path .. ";../core/?.lua"

local dump = require("dump")
local pWrapper = require("peripheralWrapper")
local gtceuIO = require("libs.gtceuIO")

local machine = pWrapper.find("blockReader")

local input = pWrapper.wrap("entangled:tile_22")
local output = pWrapper.wrap("entangled:tile_21")

local dataAccessHatch = pWrapper.find("gtceu:data_access_hatch")

local inputBuses = { gtceuIO.findInputBuses() }
local inputHatches = { gtceuIO.findInputHatches() }
print("test")
local outputBuses = { gtceuIO.findOutputBuses() }
local outputHatches = { gtceuIO.findOutputHatches() }

local function getStatus()
    local data = machine.getBlockData()

    return data.recipeLogic.status
end

local function importItems()
    local inputItems = input.list()

    local busIndex = 1
    local sentToThisBus = 0
    local currentBus = inputBuses[busIndex]
    local busSize = currentBus.size() - 1
    for fromSlot, item in pairs(inputItems) do
        if(item.name == "gtceu:data_stick") then
            print("Importing " .. item.name .. " to " .. currentBus.name)
            input.pushItems(dataAccessHatch.name, fromSlot)
        else
            if(sentToThisBus >= busSize) then
                busIndex = busIndex + 1
                sentToThisBus = 0
                currentBus = inputBuses[busIndex]
                busSize = currentBus.size() - 1
            end

            print("Importing " .. item.name .. " to " .. currentBus.name)
            input.pushItems(currentBus.name, fromSlot, 64)

            sentToThisBus = sentToThisBus + 1
        end
    end
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

local function exportItems(count)
    if(count > 3) then
        error("Failed to export some items")
    end

    for _, outputBus in pairs(outputBuses) do
        local outputItems = outputBus.list()

        for fromSlot, item in pairs(outputItems) do
            print("Exporting " .. item.name)
            outputBus.pushItems(output.name, fromSlot)
        end

        if(#outputBus.list() > 0) then
            exportItems(count + 1)
        end
    end

    local dataAccessItems = dataAccessHatch.list()

    for fromSlot, item in pairs(dataAccessItems) do
        print("Exporting " .. item.name)
        dataAccessHatch.pushItems(output.name, fromSlot)
    end

    if(#dataAccessHatch.list() > 0) then
        error("Failed to export data stick")
    end
end

while (true) do
    exportItems(0)

    if(getStatus() == "IDLE") then
        importItems()
        importFluids()
    end

    os.sleep(1)
end
