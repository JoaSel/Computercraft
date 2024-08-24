--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua test.lua

local jGui = require("src.core.jGui")
local dump = require("src.core.dump")

local monitor = peripheral.find("monitor")

monitor.clear()

monitor.setTextScale(0.5)
jGui.setMonitor(monitor)

jGui.createSlider("bulkSlider", 100, 2, 3, -2, 3, colors.red, colors.lime, "Percent")

jGui.draw()

-- local x, y = monitor.getSize()
-- monitor.setCursorPos(x - 1, 1)
-- monitor.write("Test")

