local function find(peripheralType, ignoreError)
    local peripherals = { peripheral.find(peripheralType) }

    for _, p in pairs(peripherals) do
        p.name = peripheral.getName(p)
    end

    table.sort(peripherals, function(a, b)
        return a.name < b.name
    end)

    return unpack(peripherals)
end

local function wrap(peripheralName)
    local p = peripheral.wrap(peripheralName) or error("Can't find any peripheral with name: " .. peripheralName)
    if(not p) then
        error("Could not find peripheral: " .. peripheralName)
    end

    p.name = peripheral.getName(p)

    return p
end

return { find = find, wrap = wrap }
