local function find(peripheralType)
    local peripherals = { peripheral.find(peripheralType) }

    for _, p in pairs(peripherals) do
        p.name = peripheral.getName(p)
    end

    return unpack(peripherals)
end

local function wrap(peripheralName)
    local p = peripheral.wrap(peripheralName)

    p.name = peripheral.getName(p)

    return p
end

return { find = find, wrap = wrap }
