--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meMultiBlockRequester.lua true

package.path = package.path .. ";../core/?.lua" .. ";../?.lua"

local pWrapper = require("peripheralWrapper")
local net = require("net")
local mTerm = require("moreTerm")
local dump = require("dump")
local basalt = require("basalt")

local chest = pWrapper.find("sophisticatedstorage:shulker_box")
local reader = pWrapper.find("blockReader")
local bridge = peripheral.find("meBridge")

print("test")

local function getCrafingRecipe(table, url)
    local name = url:sub(url:match('^.*()/') + 1, url:len() - 5):gsub("%.", ":")

    table[name] = net.getJson("https://raw.githubusercontent.com/JoaSel/ComputercraftLibs/main/ATM9/minecraft.crafting_shaped.json")
end

local function getCrafingRecipes()
    local ret = {};

    getCrafingRecipe(ret, "https://raw.githubusercontent.com/JoaSel/ComputercraftLibs/main/ATM9/minecraft.crafting_shaped.json")

    return ret
end

local craftingRecips = getCrafingRecipes()

local main = basalt.createFrame()
local button = main --> Basalt returns an instance of the object on most methods, to make use of "call-chaining"
        :addButton() --> This is an example of call chaining
        :setPosition(4, 4)
        :setText("Click me!")
        :onClick(
            function()
                basalt.debug("I got clicked!")
            end)

basalt.autoUpdate()