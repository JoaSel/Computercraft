---@diagnostic disable: need-check-nil

local _monitor = nil

local function setMonitor(monitor)
    _monitor = monitor
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

return
{
    setMonitor = setMonitor,
    newLine = newLine,
    writeLine = writeLine,
    writeTabbedLine = writeTabbedLine
}
