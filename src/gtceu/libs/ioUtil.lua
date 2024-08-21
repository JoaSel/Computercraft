package.path = package.path .. ";../../core/?.lua"

local pWrapper = require("peripheralWrapper")

local tiers = {"ulv", "lv", "mv", "hv", "ev", "iv", "luv", "zpm", "uv", "uhv"}

local function find(postfix)
    local ret = {}

    for _, tier in pairs(tiers) do
        local perips = { pWrapper.find("gtceu:" .. tier .. postfix) }

        for _, perip in pairs(perips) do
            table.insert(ret, perip)
        end
    end

    table.sort(ret, function (a, b)
        return a.name < b.name
    end)

    return unpack(ret)
end

local function findInputBuses()
    return find("_input_bus")
end

local function findOutputBuses()
    return find("_output_bus")
end

return { findInputBuses = findInputBuses, findOutputBuses = findOutputBuses }
