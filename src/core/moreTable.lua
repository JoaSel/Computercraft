local function find(table, predicate)
    for key, value in pairs(table) do
        if(predicate(value)) then
            return value
        end
    end
end

local function findKey(table, predicate)
    for key, value in pairs(table) do
        if(predicate(value)) then
            return key
        end
    end
end

local function removeAll(table, predicate)
    local toDelete = {}

    for key, value in pairs(table) do
        if(predicate(value)) then
            table.insert(toDelete, key)
        end
    end

    for _, deleteKey in pairs(toDelete) do
        table.remove(table, deleteKey)
    end
end

return {  find = find, findKey = findKey }