package.path = package.path .. ";../../core/?.lua"

local dump = require("dump")
local pWrapper = require("peripheralWrapper")


local function findInputBuses()
    return pWrapper.find("gtceu:ulv_input_bus")
end

return { findInputBuses = findInputBuses }
