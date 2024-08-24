--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua test.lua

local jGui = require("src.core.jGui")
local dump = require("src.core.dump")


jGui.createSlider("bulkSlider", 100, 2, 25, -2, 3, colors.red, colors.lime, "Percent")

jGui.draw()

