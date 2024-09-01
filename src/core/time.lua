local function getTime(locale)
    locale = locale or "utc"
    return textutils.formatTime(os.time(locale), true)
end

return { getTime = getTime }
