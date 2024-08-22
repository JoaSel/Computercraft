local function print(text, color)
    local oldColor = term.getTextColor()
    term.setTextColor(color or colors.pink)
    print(text)
    term.setTextColor(oldColor)
end

return { print = print }