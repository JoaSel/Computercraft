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

local function removeAll(t, predicate)
    local toRemove = {}

    for key, value in pairs(t) do
        if(predicate(value)) then
            table.insert(toRemove, key)
        end
    end

    for _, deleteKey in pairs(toRemove) do
        table.remove(t, deleteKey)
    end

    return #toRemove
end

return {  find = find, findKey = findKey, removeAll = removeAll }