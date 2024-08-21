---@diagnostic disable: param-type-mismatch
--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/craftingHistory.lua

package.path = package.path .. ";../core/?.lua"

local net = require("net")
local aeNameUtil = require("libs.aeNameUtil")

print(net.get(
	"https://raw.githubusercontent.com/JoaSel/Computercraft/main/src/ae2/libs/meRequesterData.txt"))

local bridge = peripheral.find("meBridge")
local monitor = peripheral.find("monitor")
local speaker = peripheral.find("speaker")

monitor.setTextScale(0.5)

local activeJobs = {}
local endedJobs = {}

local soundBlackList = {
	["mekanism:sulfuric_acid"] = true,
	["mekanism:oxygen"] = true,
	["mekanism:hydrogen"] = true,
	["gtceu:radon"] = true,
	["gtceu:soldering_alloy"] = true,
	["gtceu:styrene_butadiene_rubber"] = true
}

local autoRequestData = net.get(
	"https://raw.githubusercontent.com/JoaSel/Computercraft/main/src/ae2/libs/meRequesterData.txt")

local function jobStarted(cpuNum, craftingJob)
	craftingJob.startedTime = os.time("utc")
	craftingJob.lastUpdated = os.time("utc")

	activeJobs[cpuNum] = craftingJob
end

local function jobEnded(cpuNum, craftingJob)
	if (not autoRequestData[craftingJob.storage.name] and not soundBlackList[craftingJob.storage.name]) then
		speaker.playSound("minecraft:block.anvil.place")
		print(craftingJob.storage.name)
	end

	local oldJob = activeJobs[cpuNum]
	activeJobs[cpuNum] = nil

	if (oldJob ~= nil) then
		craftingJob.startedTime = oldJob.startedTime
	end

	craftingJob.endedTime = os.time("utc")

	table.insert(endedJobs, 1, craftingJob)
	table.remove(endedJobs, 20)
end

local function updateProgress(cpuNum, craftingJob)
	local activeJob = activeJobs[cpuNum]
	if (activeJob ~= nil) then
		activeJob.stuck = ((activeJob.lastUpdated - activeJob.lastUpdated) > 0.01)
		if (craftingJob.progress > activeJob.progress) then
			activeJob.progress = craftingJob.progress
			activeJob.lastUpdated = os.time("utc")
		end
	end
end

local function getProgressText(activeJob)
	return "(" .. math.floor((activeJob.progress / activeJob.totalItem) * 100) .. "%) "
end

local function writeLine(text, color)
	if (color ~= nil) then
		local oldColor = monitor.getTextColor()
		monitor.setTextColor(color)
		monitor.write(text)
		monitor.setTextColor(oldColor)
	else
		monitor.write(text)
	end

	local _, y = monitor.getCursorPos()
	monitor.setCursorPos(1, y + 1)
end

local function getTimeStamp(time)
	if (time == nil) then
		return "??:??"
	end

	local formattedText = textutils.formatTime(time, true)
	if (string.len(formattedText) < 5) then
		formattedText = "0" .. formattedText
	end

	return formattedText
end

local function render()
	monitor.clear()

	monitor.setCursorPos(1, 1)
	if (next(activeJobs) ~= nil) then
		writeLine("Currently Crafting:")
		for _, activeJob in pairs(activeJobs) do
			local color = colors.yellow
			if (activeJob.stuck) then
				color = color.red
			end
			writeLine(
				"\t[" ..
				getTimeStamp(activeJob.startedTime) ..
				"] " ..
				activeJob.storage.amount ..
				" " .. aeNameUtil.toDisplayName(activeJob.storage.displayName) .. "\t" .. getProgressText(activeJob),
				color)
		end
	end

	monitor.setCursorPos(1, 10)
	if (next(endedJobs) ~= nil) then
		writeLine("Finished Crafting:")
		for _, endedJob in pairs(endedJobs) do
			writeLine(
				"\t[" ..
				getTimeStamp(endedJob.startedTime) ..
				" => " ..
				getTimeStamp(endedJob.endedTime) ..
				"] " .. endedJob.storage.amount .. " " .. aeNameUtil.toDisplayName(endedJob.storage.displayName),
				colors.green)
		end
	end

	os.sleep(0.1)
end

local lastCpuInfos = nil
while (true) do
	local cpuInfos = bridge.getCraftingCPUs()
	if (cpuInfos ~= nil) then
		if (lastCpuInfos == nil) then
			lastCpuInfos = cpuInfos
		end

		for cpuNum, cpuInfo in pairs(cpuInfos) do
			local lastCpuInfo = lastCpuInfos[cpuNum]
			if (lastCpuInfo ~= nil) then
				if (cpuInfo.craftingJob ~= nil and lastCpuInfo.craftingJob == nil) then
					jobStarted(cpuNum, cpuInfo.craftingJob)
				end
				if (cpuInfo.craftingJob == nil and lastCpuInfo.craftingJob ~= nil) then
					jobEnded(cpuNum, lastCpuInfo.craftingJob)
				end
				updateProgress(cpuNum, cpuInfo.craftingJob)
			end
		end
		lastCpuInfos = cpuInfos
	end

	render()
end
