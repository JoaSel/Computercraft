local function find(peripheralType)
    local peripherals = { peripheral.find(peripheralType) }

    for _, p in pairs(peripherals) do
        peripheral.name = peripheral.getName(p)
    end

    return unpack(peripherals)
end

local function wrap(peripheralName)
    local peripheral = peripheral.wrap(peripheralName)

    peripheral.name = peripheral.getName(p)

    return peripheral
end

return { find = find, wrap = wrap }
