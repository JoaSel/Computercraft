--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/gtceu/machineClient.lua

package.path = package.path .. ";../core/?.lua"

local dump = require("dump")
local mTable = require("moreTable")
local pWrapper = require("peripheralWrapper")
local gtceuIO = require("libs.gtceuIO")
local mString = require("moreString")

local sendChannel = 43
local ackChannel = 44

local modem = pWrapper.find("modem", function(_, modem)
    return modem.isWireless()
end)

local blockReader = pWrapper.find("blockReader")

local inputBuses = { gtceuIO.findInputBuses() }
local inputHatches = { gtceuIO.findInputHatches() }

local allowedItems = {
    ["gtceu:programmed_circuit"] = true,
    ["alltheores:zinc_dust"] = true,
    ["gtceu:blue_glass_lens"] = true,
    ["gtceu:brown_glass_lens"] = true,
    ["gtceu:light_blue_glass_lens"] = true,
    ["gtceu:gray_glass_lens"] = true,
    ["gtceu:green_glass_lens"] = true,
    ["gtceu:lime_glass_lens"] = true,
    ["gtceu:orange_glass_lens"] = true,
    ["gtceu:pink_glass_lens"] = true,
    ["gtceu:yellow_glass_lens"] = true,
    ["gtceu:huge_pipe_extruder_mold"] = true,
    ["gtceu:large_pipe_extruder_mold"] = true,
    ["gtceu:normal_pipe_extruder_mold"] = true,
    ["gtceu:small_pipe_extruder_mold"] = true,
    ["gtceu:tiny_pipe_extruder_mold"] = true,
    ["gtceu:long_rod_extruder_mold"] = true,
    ["gtceu:gear_extruder_mold"] = true,
    ["gtceu:small_gear_extruder_mold"] = true,
    ["gtceu:rotor_extruder_mold"] = true,
    ["gtceu:ring_extruder_mold"] = true
}

local machineName = blockReader.getBlockName()

local category
local name

local split = mString.split(os.getComputerLabel(), "-")

dump.toTerm(split)

if (#split == 1) then
  category = "Unkown"
  name = split[1]
else
  category = split[1]
  name = split[2]
end

local filterItems = function(item)
    return allowedItems[item.name]
end

print(string.format("Monitoring %s", machineName))
print(string.format("Category: ", machineName, category))
print(string.format("Name: ", machineName, name))

local function getMachineStatus()
    local data = {}

    data.machineCategory = category
    data.machineName = name

    data.hasInputItems = false
    for _, inputBus in pairs(inputBuses) do
        local items = inputBus.list()
        mTable.removeAll(items, filterItems)
        if (next(items)) then
            data.hasInputItems = true
        end
    end

    data.hasInputFluids = false
    for _, inputHatch in pairs(inputHatches) do
        if (next(inputHatch.tanks())) then
            data.hasInputFluids = true
        end
    end

    data.blockData = blockReader.getBlockData()
    if (data.blockData.recipeLogic) then
        data.blockData.recipeLogic.lastRecipe = nil
        data.blockData.recipeLogic.lastOriginRecipe = nil
    end

    return data
end


while (true) do
    local status = getMachineStatus()

    if (status) then
        modem.transmit(sendChannel, ackChannel, status)
    end

    os.sleep(2)
end
