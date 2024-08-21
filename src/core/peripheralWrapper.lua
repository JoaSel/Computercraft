

local function find(peripheralType)
    local peripherals = { peripheral.find(peripheralType) }

    for _, p in pairs(peripherals) do
        peripheral.name = peripheral.getName(p)
    end

    return peripherals

end

return { find = find }
