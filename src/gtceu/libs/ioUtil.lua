package.path = package.path .. ";../../core/?.lua"

local pWrapper = require("peripheralWrapper")

local tiers = {"ulv", "lv", "mv", "hv", "ev", "iv", "luv", "zpm", "uv", "uhv"}

local function findInputBuses()
    local ret = {}

    for _, tier in pairs(tiers) do
        local perips = { pWrapper.find("gtceu:" .. tier .. "_input_bus") }

        for _, perip in pairs(perips) do
            table.insert(ret, perip)
        end
    end

    table.sort(ret, function (a, b)
        return a.name < b.name
    end)

    return unpack(ret)
end

local function findOutputBuses()
    local ret = {}

    for _, tier in pairs(tiers) do
        local perips = { pWrapper.find("gtceu:" .. tier .. "_output_bus") }

        for _, perip in pairs(perips) do
            table.insert(ret, perip)
        end
    end

    table.sort(ret, function (a, b)
        return a.name < b.name
    end)

    return unpack(ret)
end

return { findInputBuses = findInputBuses, findOutputBuses = findOutputBuses }
