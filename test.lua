--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua test.lua

local jGui = require("src.core.jGui")
local dump = require("src.core.dump")

local monitor = peripheral.find("monitor")

monitor.setTextScale(0.5)
monitor.clear()

jGui.setMonitor(monitor, true)

jGui.createSlider("bulkSlider", 100, 2, 2, -2, 2, colors.red, colors.lime, "Percent")

jGui.draw()

-- while true do
    
-- end

-- local x, y = monitor.getSize()
-- monitor.setCursorPos(x, 1)
-- monitor.write("Test")

