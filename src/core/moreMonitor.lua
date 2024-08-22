---@diagnostic disable: need-check-nil

local _monitor = nil

local function setMonitor(monitor)
    _monitor = monitor
end

local function newLine()
    local _, y = _monitor.getCursorPos()
    _monitor.setCursorPos(1, y + 1)
end

return
{
    setMonitor = setMonitor,
    newLine = newLine
}
