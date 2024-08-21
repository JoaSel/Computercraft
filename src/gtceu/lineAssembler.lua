--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/gtceu/lineAssembler.lua

package.path = package.path .. ";../core/?.lua"

local dump = require("dump")

local machine = peripheral.find("blockReader")

local function isIdle()
    local data = machine.getBlockData()

    return data.status == "IDLE"
end

print(isIdle())
dump.printDump(machine.getBlockData())

