local function cprint(text, textColor)
    local oldColor = term.getTextColor()
    term.setTextColor(textColor or colors.pink)
    print(text)
    term.setTextColor(oldColor)
end

return { cprint = cprint }