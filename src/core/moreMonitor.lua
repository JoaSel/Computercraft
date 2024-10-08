---@diagnostic disable: need-check-nil

local _monitor = nil
local _oldColor = nil
local _mWidth = nil

local function setMonitor(monitor, textScale)
    _monitor = monitor
	
	if(textScale) then
		_monitor.setTextScale(textScale)
	end

    _oldColor = _monitor.getTextColor()
	_mWidth, _ = _monitor.getSize()
end

local function reset()
	_monitor.clear()
	_monitor.setCursorPos(1, 1)
end

local function newLine()
    local _, y = _monitor.getCursorPos()
    _monitor.setCursorPos(1, y + 1)
end

local function writeLine(text, color)
	if (color ~= nil) then
		local oldColor = _monitor.getTextColor()
		_monitor.setTextColor(color)
		_monitor.write(text)
		_monitor.setTextColor(oldColor)
	else
		_monitor.write(text)
	end

	local _, y = _monitor.getCursorPos()
	_monitor.setCursorPos(1, y + 1)
end

local function writeTabbedLine(tabData, ...)
	local texts = { ... }
	local y
	local i = 1
	local currTab = 0

	for _, text in pairs(texts) do
		_monitor.write(text)
		_, y = _monitor.getCursorPos()
		currTab = currTab + tabData[i]
		_monitor.setCursorPos(currTab, y)
		i = i + 1
	end

	_monitor.setCursorPos(1, y + 1)
end

local function toggleColor(color)
    if(color) then
        _oldColor = _monitor.getTextColor()
        _monitor.setTextColor(color)
    else
        _monitor.setTextColor(_oldColor)
    end
end

local function writeCenter(text, color, row)
	local _, y = _monitor.getCursorPos()
	_monitor.setCursorPos(math.floor((_mWidth / 2) - (#text / 2)) + 1, row or y)

	if (color ~= nil) then
		local oldColor = _monitor.getTextColor()
		_monitor.setTextColor(color)
		_monitor.write(text)
		_monitor.setTextColor(oldColor)
	else
		_monitor.write(text)
	end

	_monitor.setCursorPos(1, y + 1)
end


return
{
    setMonitor = setMonitor,
    newLine = newLine,
    writeLine = writeLine,
    writeTabbedLine = writeTabbedLine,
	toggleColor = toggleColor,
	writeCenter = writeCenter,
	reset = reset
}
