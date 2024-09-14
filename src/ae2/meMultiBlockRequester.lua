--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meMultiBlockRequester.lua true

package.path = package.path .. ";../core/?.lua" .. ";../../../?.lua"

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
local flex = main
  :addFlexbox()
  :setForeground(colors.white)
  :setBackground(colors.black)
  :setWrap("wrap")
  :setPosition(1, 2)
  :setSize("parent.w", "parent.h - 1")

local button = flex
        :addButton()
        :setText("Click me!")
        :onClick(
            function()
                basalt.debug("I got clicked!")
            end)

basalt.autoUpdate()