--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua test.lua

local pWrapper = require("src.core.peripheralWrapper")
local dump = require("src.core.dump")

local x = pWrapper.find("blockReader")

for index, value in pairs(x.getBlockData().recipeLogic) do
    print(index)
    print(value)
end

dump.easy(x.getBlockData().recipeLogic.lastOriginRecipe)