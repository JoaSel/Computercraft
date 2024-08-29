--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/gtceu/machineClient.lua

package.path = package.path .. ";../core/?.lua"

local dump = require("dump")
local pWrapper = require("peripheralWrapper")
local gtceuIO = require("libs.gtceuIO")

local modem = pWrapper.find("modem")
local blockReader = pWrapper.find("blockReader")



--print(string.format("Monitoring %s...", machineName))

while(true) do
local machineName = blockReader.getName()
    local data = blockReader.getBlockData()

    if(data) then
        if(data.recipeLogic.lastRecipe) then
            data.recipeLogic.lastRecipe = nil
        end
        if(data.recipeLogic.lastOriginRecipe) then
            data.recipeLogic.lastOriginRecipe = nil
        end

        data.machineName = machineName

        modem.transmit(43, 43, data)
    end

    os.sleep(2)
end
