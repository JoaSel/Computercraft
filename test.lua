--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua test.lua

package.path = package.path .. ";./src/core/?.lua"

local jGui = require("jGui")
local dump = require("dump")

local monitor = peripheral.find("monitor")

monitor.setTextScale(0.5)
monitor.clear()

jGui.setMonitor(monitor)

jGui.createSlider("testSlider", 100, -2, 2, colors.red, colors.lime, "Percent")

jGui.draw("testSlider")

monitor.setCursorPos(5, 5)

jGui.draw("testSlider")

-- while true do
    
-- end

-- local x, y = monitor.getSize()
-- monitor.setCursorPos(x, 1)
-- monitor.write("Test")

