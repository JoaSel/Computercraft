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

local unstackableItems = {
	["minecraft:bundle"] = true
}

local bulkStorages = { pWrapper.find("dankstorage:dank_tile") }
local bulkStorageI = 1

local nbtStorages = { pWrapper.find("entangled:tile") }
local nbtStorageI = 1
local nbtStorageLimit = 1024

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

local function createCapacityBar(name, row)
	mainPage.frame
		:addLabel()
		:setText(name)
		:setTextAlign("center")
		:setSize("parent.w", 1)
		:setPosition(1, row)

	mainPage.frame
		:addProgressbar()
		:setDirection("right")
		:setProgress(50)
		:setProgressBar(colors.green)
		:setBackground(colors.red)
		:setPosition("parent.w * 0.125", row + 1)
		:setSize("parent.w * 0.75", 2)
		:setZIndex(1)

	mainPage.frame
		:addLabel()
		:setText(" 50%")
		:setPosition("(parent.w / 2) - 1", row + 2)
		:setZIndex(2)
		:setForeground(colors.black)
		:setTextAlign("center")
end

createCapacityBar("Bulk Item Storage", 1);
createCapacityBar("NBT Item Storage", 5);

local function defrag()
end

base:addThread():start(defrag)

basalt.autoUpdate();