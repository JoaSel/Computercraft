---@diagnostic disable: need-check-nil

local sliders = {}
local _monitor = nil
local _mWidth = 0

local None = 0
local Percent = 1
local Numbers = 2

local function setMonitor(monitor)
	if not (monitor.isColor()) then
		error("Monitor Doesn't Support Colors")
	end
	_monitor = monitor
	_, _mWidth = _monitor.getSize()
end

local function createSlider(name, maxValue, x, y, length, height, sliderColor, barColor, infoType)
	if (sliders[name]) then
		error(name .. " already exist!")
	end

	if sliderColor == nil then
		sliderColor = colors.gray
	end
	if barColor == nil then
		barColor = colors.white
	end
	if infoType == nil then
		infoType = 1
	end
	if(y < 0) then
		y = _mWidth - y
		print(y)
	end

	-- fills in values
	sliders[name] = {}
	sliders[name]["maxValue"] = maxValue
	sliders[name]["x"] = x
	sliders[name]["y"] = y
	sliders[name]["length"] = length
	sliders[name]["height"] = height
	sliders[name]["sliderColor"] = sliderColor
	sliders[name]["barColor"] = barColor
	sliders[name]["value"] = 0
	sliders[name]["textColor"] = colors.black
	sliders[name]["infoType"] = infoType
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

local function drawCenterInfo(v, text, percentDraw)
	local textX = math.floor(v.x + (v.length / 2) - (#text / 2))
	local textY = math.floor(v.y + v.height - (v.height / 2))

	_monitor.setCursorPos(textX, textY)
	_monitor.setTextColor(v.textColor)

	for i = 0, #text do
		if (textX + i > percentDraw + 2) then
			_monitor.setBackgroundColor(v.barColor)
		else
			_monitor.setBackgroundColor(v.sliderColor)
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

local function draw(name)
	if _monitor == nil then
		setMonitor(term)
		if not (_monitor.isColor()) then
			error("Monitor doesn't support Colors")
		end
	end

	if not (type(name) == "table") then
		if not (type(name) == "string") then
			name = {}
			for k, v in pairs(sliders) do
				table.insert(name, k)
			end
		else
			name = { name }
		end
	end

	for k, v in pairs(sliders) do
		for s = 0, #name + 1 do
			if k == name[s] then
				local percentDraw = v.length * (v.value / v.maxValue)
				for yPos = v.y, v.y + v.height - 1 do
					_monitor.setBackgroundColor(v.barColor)
					_monitor.setCursorPos(v.x, yPos)
					_monitor.write(string.rep(" ", v.length))

					_monitor.setCursorPos(v.x, yPos)
					_monitor.setBackgroundColor(v.sliderColor)
					_monitor.write(string.rep(" ", percentDraw))

					if (v.infoType == 1) then
						drawPercent(v, percentDraw)
					end
					if (v.infoType == 2) then
						drawNumbers(v, percentDraw)
					end
				end
			end
		end

		_monitor.setBackgroundColor(colors.black)
		_monitor.setTextColor(colors.white)
		_monitor.setCursorPos(1, 1)
	end
end

return {
	setMonitor = setMonitor,
	createSlider = createSlider,
	updateSlider = updateSlider,
	draw = draw
}
