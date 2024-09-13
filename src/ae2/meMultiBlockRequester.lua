--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meMultiBlockRequester.lua

package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")
local net = require("net")
local mTerm = require("moreTerm")
local dump = require("dump")

local chest = pWrapper.find("sophisticatedstorage:shulker_box")
local reader = pWrapper.find("blockReader")
local bridge = peripheral.find("meBridge")

print("test")

local function getCrafingRecipe(table, url)
    local index = url:match('^.*()/')
    local name = url:sub(index+1, url:len() - 4)
    print(name)

    --net.getJson("https://raw.githubusercontent.com/JoaSel/ComputercraftLibs/main/ATM9/minecraft.crafting_shaped.json")
end

local function getCrafingRecipes()
    local ret = {};
    --net.getJson()
    getCrafingRecipe(ret, "https://raw.githubusercontent.com/JoaSel/ComputercraftLibs/main/ATM9/minecraft.crafting_shaped.json")

    return ret
end

local craftingRecips = getCrafingRecipes()