--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meDefragmenter.lua true

package.path = package.path .. ";../core/?.lua"
package.path = package.path .. ";../../../?.lua"

local pWrapper = require("peripheralWrapper")

local basalt = require("basalt")
local mTable = require("moreTable")
local mString = require("moreString")
local dump = require("dump")

local monitor = pWrapper.find("monitor")

monitor.setTextScale(0.5)

local mainPage = {}

local base = basalt.addMonitor()
    :setForeground(colors.white)
    :setBackground(colors.black)
    :setMonitor(monitor)

mainPage.frame = base
    :addFrame()
    :setForeground(colors.white)
    :setBackground(colors.black)
    :setPosition(1, 1)
    :setSize("parent.w", "parent.h - 1")

mainPage.frame
	:addLabel()
	:setText("Bulk Item Storage")
	:setTextAlign("center")
	:setSize("parent.w", "1")
	:setPosition(1, 1)

mainPage.frame
	:addProgressbar()
	:setDirection("right")
	:setProgress(50)
	:setProgressBar(colors.green)
	:setBackground(colors.red)
	:setPosition("parent.w * 0.125", 2)
	:setSize("parent.w * 0.75", 2)

mainPage.frame
	:addLabel()
	:setText("NBT Item Storage")
	:setTextAlign("center")
	:setSize("parent.w", "1")
	:setPosition(1, 5)

mainPage.frame
	:addProgressbar()
	:setDirection("right")
	:setProgress(50)
	:setProgressBar(colors.green)
	:setBackground(colors.red)
	:setPosition("parent.w * 0.125", 6)
	:setSize("parent.w * 0.75", 2)
	:setZIndex(1)

mainPage.frame
	:addLabel()
	:setText("testing")
	:setPosition("parent.w * 0.125", 6)
	:setZIndex(2)


basalt.autoUpdate();