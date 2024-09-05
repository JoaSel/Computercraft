--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/gtceu/machineClient.lua

package.path = package.path .. ";../core/?.lua"

local dump = require("dump")
local pWrapper = require("peripheralWrapper")
local gtceuIO = require("libs.gtceuIO")

local sendChannel = 43
local ackChannel = 44

local modem = pWrapper.find("modem", function(_, modem)
    return modem.isWireless()
end)
local blockReader = pWrapper.find("blockReader")

local inputBuses = { gtceuIO.findInputBuses() }
local inputHatches = { gtceuIO.findInputHatches() }

local machineName = blockReader.getBlockName()
local label = computer.getLabel()

print(label)

print(string.format("Monitoring %s...", machineName))

local function getMachineStatus()
    local data = blockReader.getBlockData()

    if (data) then
        if (data.recipeLogic) then
            if (data.recipeLogic.lastRecipe) then
                data.recipeLogic.lastRecipe = nil
            end
            if (data.recipeLogic.lastOriginRecipe) then
                data.recipeLogic.lastOriginRecipe = nil
            end
        end

        data.machineId = machineName
        data.machineName = machineName

        data.hasInputItems = false
        for _, inputBus in pairs(inputBuses) do
            if(next(inputBus.list())) then
                data.hasInputItems = true
            end
        end

        data.hasInputFluids = false
        for _, inputHatch in pairs(inputHatches) do
            if(next(inputHatch.tanks())) then
                data.hasInputFluids = true
            end
        end

        return data
    end
end


while (true) do
    local status = getMachineStatus()

    if (status) then
        modem.transmit(sendChannel, ackChannel, status)
    end

    os.sleep(2)
end
