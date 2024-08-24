---@diagnostic disable: need-check-nil

local mTable = require("moreTable")
local dump = require("dump")

local sliders = {}
local _monitor = nil
local _mWidth = 0

local infoTypeLookup = {
	["None"] = 0,
	["Percent"] = 1,
	["Numbers"] = 2
}

local function setMonitor(monitor)
	if not (monitor.isColor()) then
		error("Monitor Doesn't Support Colors")
	end
	_monitor   = monitor
	_mWidth, _ = _monitor.getSize()
end

local function click(x, y)
	local hit = mTable.firstOrDefault(sliders, function (s)
		return x >= s.hitBox.xMin and x <= s.hitBox.xMax and y >= s.hitBox.yMin and x <= s.hitBox.yMax
	end)

	if(not hit or not hit.onClick) then
		return
	end

	hit.onClick()
end

local function createSlider(name, maxValue, length, height, barForegroundColor, barBackgroundColor, infoType, onClick)
	if (sliders[name]) then
		error(name .. " already exist!")
	end

	if barForegroundColor == nil then
		barForegroundColor = colors.gray
	end
	if barBackgroundColor == nil then
		barBackgroundColor = colors.white
	end
	if(infoType == nil or infoTypeLookup[infoType] == nil) then
		infoType = 1
	else
		infoType = infoTypeLookup[infoType]
	end
	-- if(length <= 0) then
	-- 	length = _mWidth + length - x + 1
	-- end

	-- fills in values
	sliders[name] = {}
	sliders[name].maxValue = maxValue
	-- sliders[name].x = x
	-- sliders[name].y = y
	sliders[name].length = length
	sliders[name].height = height
	sliders[name].barForegroundColor = barForegroundColor
	sliders[name].barBackgroundColor = barBackgroundColor
	sliders[name].value = 0
	sliders[name].textColor = colors.black
	sliders[name].infoType = infoType

	dump.easy(sliders[name])

	sliders[name].onClick = onClick
end

local function updateSlider(name, value)
	local slider = sliders[name]
	if (slider) then
		if (value > slider.maxValue) then
			value = slider.maxValue
		elseif value < 0 then
			error(name .. ": Value can not be under 0!")
		end
		slider.value = value
	end
end

local function drawCenterInfo(slider, text, percentDraw)
	local textX = math.floor(slider.x + (slider.length / 2) - (#text / 2))
	local textY = math.floor(slider.y + slider.height - (slider.height / 2))

	_monitor.setCursorPos(textX, textY)
	_monitor.setTextColor(slider.textColor)

	for i = 0, #text do
		-- if (textX + i > percentDraw + 2) then
		-- 	_monitor.setBackgroundColor(slider.barBackgroundColor)
		-- else
		-- 	_monitor.setBackgroundColor(slider.barForegroundColor)
		-- end
		_monitor.write(string.sub(text, i, i))
	end
end

local function drawPercent(v, percentDraw)
	local text = math.floor(v.value * 100 / v.maxValue) .. "%"
	drawCenterInfo(v, text, percentDraw)
end

local function drawNumbers(v, percentDraw)
	local text = v.value .. " / " .. v.maxValue
	drawCenterInfo(v, text, percentDraw)
end

local function draw(sliderName)
	local oldColor = _monitor.getTextColor()

	local slider = sliders[sliderName]
	if(not slider) then
		return
	end

	local startX, startY = _monitor.getCursorPos()

	slider.x = startX
	slider.y = startY

	local percentDraw = slider.length * (slider.value / slider.maxValue)
	for yPos = slider.y, slider.y + slider.height - 1 do
		print(yPos)
		_monitor.setBackgroundColor(slider.barBackgroundColor)
		_monitor.setCursorPos(startX, yPos)
		_monitor.write(string.rep(" ", slider.length))

		_monitor.setCursorPos(startX, yPos)
		_monitor.setBackgroundColor(slider.barForegroundColor)
		_monitor.write(string.rep(" ", percentDraw))
		print(_monitor.getCursorPos())

		if (slider.infoType == 1) then
			drawPercent(slider, percentDraw)
		end
		if (slider.infoType == 2) then
			drawNumbers(slider, percentDraw)
		end
	end

	_monitor.setTextColor(oldColor)
	_monitor.setCursorPos(1, startY + slider.height)
end

return {
	setMonitor = setMonitor,
	createSlider = createSlider,
	updateSlider = updateSlider,
	draw = draw,
	click = click
}
