--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/gtceu/machineClient.lua

package.path = package.path .. ";../core/?.lua"

local dump = require("dump")
local pWrapper = require("peripheralWrapper")
local gtceuIO = require("libs.gtceuIO")

local modem = pWrapper.find("modem")
local blockReader = pWrapper.find("bloackReader")


while(true) do
    local data = blockReader.getBlockData()

    if(data) then
        modem.transmit(43, 43, data)
    end

    os.sleep(2)
end

