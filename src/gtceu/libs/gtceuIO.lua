package.path = package.path .. ";../../core/?.lua"

local pWrapper = require("peripheralWrapper")

local tiers = { "ulv", "lv", "mv", "hv", "ev", "iv", "luv", "zpm", "uv", "uhv" }

local function find(postfix)
    local ret = {}

    for _, tier in pairs(tiers) do
        local perips = { pWrapper.find("gtceu:" .. tier .. postfix, true) }

        for _, perip in pairs(perips) do
            table.insert(ret, perip)
        end

        perips = { pWrapper.find("gtceu:" .. tier .. postfix .. "_4x", true) }
        for _, perip in pairs(perips) do
            table.insert(ret, perip)
        end

        perips = { pWrapper.find("gtceu:" .. tier .. postfix .. "_9x", true) }
        for _, perip in pairs(perips) do
            table.insert(ret, perip)
        end
    end

    table.sort(ret, function(a, b)
        local aLen = string.len(a.name)
        local bLen = string.len(b.name)
        if(aLen == bLen) then
            return a.name < b.name
        end
        return aLen < bLen
    end)

    return unpack(ret)
end

local function findInputBuses()
    return find("_input_bus")
end

local function findInputHatches()
    return find("_input_hatch")
end

local function findOutputBuses()
    return find("_output_bus")
end

local function findOutputHatches()
    return find("_output_hatch")
end

return {
    findInputBuses = findInputBuses,
    findOutputBuses = findOutputBuses,
    findInputHatches = findInputHatches,
    findOutputHatches = findOutputHatches
}
