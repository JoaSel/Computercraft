package.path = package.path .. ";../../core/?.lua"

local dump = require("dump")
local pWrapper = require("peripheralWrapper")


local function findInputBuses()
    local ulv = pWrapper.find("gtceu:ulv_input_bus")
    local lv = pWrapper.find("gtceu:lv_input_bus")

    dump.printDump(lv)

    return ulv
end

return { findInputBuses = findInputBuses }
