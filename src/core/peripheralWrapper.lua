

local function find(peripheralType)
    local peripherals = { peripheral.find(peripheralType) }

    for _, p in pairs(peripherals) do
        peripheral.name = peripheral.getName(p)
    end

    return unpack(peripherals)
end

return { find = find }
