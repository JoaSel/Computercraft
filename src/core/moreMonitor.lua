---@diagnostic disable: need-check-nil

local _monitor = nil
local _oldColor = nil
local _mWidth = nil

local function setMonitor(monitor)
    _monitor = monitor
    _oldColor = _monitor.getTextColor()
	_mWidth, _ = _monitor.getSize()
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

local function writeCenter(text, line)
	local y = 0
	if(line) then
		y = line
	else
		_, y = _monitor.getCursorPos()
	end

	_monitor.setCursorPos(math.floor((_mWidth / 2) - (#text / 2)) + 1, y)
	_monitor.write(text)
end


return
{
    setMonitor = setMonitor,
    newLine = newLine,
    writeLine = writeLine,
    writeTabbedLine = writeTabbedLine,
	toggleColor = toggleColor,
	writeCenter = writeCenter
}
