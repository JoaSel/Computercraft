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
		return x >= s.x and x <= s.x + s.length and y >= s.y and x <= s.y + s.height
	end)

	print("---------------")
	print("Clicked")
	print(x)
	print(y)

	local slider = sliders[next(sliders)]

	print("---------------")

	print(slider.x)
	print(slider.y)
	print(slider.length)
	print(slider.height)

	print("---------------")

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

	sliders[name] = {}
	sliders[name].maxValue = maxValue
	sliders[name].originalLength = length
	sliders[name].height = height
	sliders[name].barForegroundColor = barForegroundColor
	sliders[name].barBackgroundColor = barBackgroundColor
	sliders[name].value = 0
	sliders[name].textColor = colors.black
	sliders[name].infoType = infoType

	sliders[name].x = 1000
	sliders[name].y = 1000
	sliders[name].length = 0

	sliders[name].onClick = onClick
end

local function updateSliderValue(name, value)
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

local function updateSliderMaxValue(name, maxValue)
	local slider = sliders[name]
	if (slider) then
		if maxValue < 0 then
			error(name .. ": Max value can not be under 0!")
		end
		slider.maxValue = maxValue
	end
end

local function drawCenterInfo(slider, text, percentDraw)
	local textX = math.floor(slider.x + (slider.length / 2) - (#text / 2))
	local textY = math.floor(slider.y + slider.height - (slider.height / 2))

	_monitor.setCursorPos(textX, textY)
	_monitor.setTextColor(slider.textColor)

	for i = 0, #text do
		if (textX + i > percentDraw + 4) then
			_monitor.setBackgroundColor(slider.barBackgroundColor)
		else
			_monitor.setBackgroundColor(slider.barForegroundColor)
		end
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

local function draw(sliderName, indent)
	local oldColor = _monitor.getTextColor()
	local oldBackgroundColor = _monitor.getBackgroundColor()

	local slider = sliders[sliderName]
	if(not slider) then
		return
	end
	local startX, startY = _monitor.getCursorPos()

	slider.x = startX + (indent or 0)
	slider.y = startY
	slider.length = slider.originalLength > 0 and slider.originalLength or _mWidth + slider.originalLength - slider.x

	local percentDraw = slider.length * (slider.value / slider.maxValue)
	for yPos = slider.y, slider.y + slider.height - 1 do
		_monitor.setBackgroundColor(slider.barBackgroundColor)
		_monitor.setCursorPos(slider.x, yPos)
		_monitor.write(string.rep(" ", slider.length))

		_monitor.setCursorPos(slider.x, yPos)
		_monitor.setBackgroundColor(slider.barForegroundColor)
		_monitor.write(string.rep(" ", percentDraw))

		if (slider.infoType == 1) then
			drawPercent(slider, percentDraw)
		end
		if (slider.infoType == 2) then
			drawNumbers(slider, percentDraw)
		end
	end

	_monitor.setTextColor(oldColor)
	_monitor.setBackgroundColor(oldBackgroundColor)
	_monitor.setCursorPos(1, startY + slider.height)
end

return {
	setMonitor = setMonitor,
	createSlider = createSlider,
	updateSliderValue = updateSliderValue,
	updateSliderMaxValue = updateSliderMaxValue,
	draw = draw,
	click = click
}
