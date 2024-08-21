package.path = package.path .. ";../../core/?.lua"

local dump = require("dump")
local pWrapper = require("peripheralWrapper")
local function findInputBuses()
    local all = {
        { pWrapper.find("gtceu:ulv_input_bus") },
        { pWrapper.find("gtceu:lv_input_bus") },
        { pWrapper.find("gtceu:mv_input_bus") },
        { pWrapper.find("gtceu:hv_input_bus") },
        { pWrapper.find("gtceu:ev_input_bus") },
        { pWrapper.find("gtceu:iv_input_bus") },
        { pWrapper.find("gtceu:luv_input_bus") },
        { pWrapper.find("gtceu:zpm_input_bus") },
        { pWrapper.find("gtceu:uv_input_bus") },
        { pWrapper.find("gtceu:uhv_input_bus") },
    }

    local ret = {}
    for _, perips in pairs(all) do
        for _, p in pairs(perips) do
            table.insert(ret, p)
        end
    end

    table.sort(ret, function (a, b)
        return a.name < b.name
    end)

    return unpack(ret)
end

return { findInputBuses = findInputBuses }
