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

local translate = {
    ["minecraft:crafting_shaped"] = "Shaped"
}

local function getCrafingRecipe(table, url)
    local name = url:sub(url:match('^.*()/') + 1, url:len() - 5):gsub("%.", ":")

    table[name] = net.getJson(
        "https://raw.githubusercontent.com/JoaSel/ComputercraftLibs/main/ATM9/minecraft.crafting_shaped.json")
end

local function getCrafingRecipes()
    local ret = {};

    getCrafingRecipe(ret,
        "https://raw.githubusercontent.com/JoaSel/ComputercraftLibs/main/ATM9/minecraft.crafting_shaped.json")

    return ret
end

local craftingRecipes = getCrafingRecipes()
local main = basalt.createFrame()
local flex = main
    :addFlexbox()
    -- :setForeground(colors.white)
    -- :setBackground(colors.black)
    :setWrap("wrap")
    :setPosition(1, 1)
    :setSize("parent.w", "parent.h")

for category, recipes in pairs(craftingRecipes) do
    local categoryName = translate[category] or category
    local categoryFrame = basalt.createFrame()
        :hide()

    categoryFrame:addLabel()
        :setText(categoryName)

    basalt.debug(category)
    flex:addButton()
        :setText(categoryName)
        :onClick(
            function()
                main:hide()
                categoryFrame:show()
            end)
end

basalt.autoUpdate()
