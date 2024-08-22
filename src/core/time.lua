local lastCalled = os.time("utc")

local function sleep(secondsShort, secondsLong)
    print(os.time("utc"))
    print(os.time())
end

return { sleep = sleep }
