---@diagnostic disable: param-type-mismatch

local net = require()

--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/AE2/craftingHistory.lua

local bridge = peripheral.find("meBridge")
local monitor = peripheral.find("monitor")
local speaker = peripheral.find("speaker")

--replace §9  and §r

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

local function getRequestData()
	local socket = http.get("https://raw.githubusercontent.com/JoaSel/Computercraft/main/src/AE2/meRequesterData.txt")
	if (not socket) then
		error("Could not get request data.")
	end

	local content = socket.readAll()
	if (not content) then
		error("Could not get request data.")
	end
	
	socket.close()

	local parsed = textutils.unserialize(content)
	if (not parsed) then
		error("Could not unserialize request data.")
	end

	return parsed
end

local autoRequestData = getRequestData()

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
	if (activeJob ~= nil and craftingJob.progress > activeJob.progress) then
		activeJob.progress = craftingJob.progress
		activeJob.lastUpdated = os.time("utc")
		activeJob.stuck = ((activeJob.lastUpdated - activeJob.lastUpdated) > 0.01)
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
			activeJob.storage.amount .. " " .. activeJob.storage.displayName .. "\t" .. getProgressText(activeJob), color)
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
			getTimeStamp(endedJob.endedTime) .. "] " .. endedJob.storage.amount .. " " .. endedJob.storage.displayName,
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
