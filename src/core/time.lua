---@diagnostic disable: param-type-mismatch

local lastCalled = os.time("utc")

local function sleep(secondsShort, secondsLong)

end

return { sleep = sleep }
