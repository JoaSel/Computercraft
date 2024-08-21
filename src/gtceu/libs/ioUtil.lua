package.path = package.path .. ";../../core/?.lua"

local dump = require("dump")
local pWrapper = require("peripheralWrapper")
local function findInputBuses()
    local all = {
        { pWrapper.find("gtceu:ulv_input_bus") },
        { pWrapper.find("gtceu:lv_input_bus") }
    }

    dump.printDump(all)

    return nil
end

return { findInputBuses = findInputBuses }
