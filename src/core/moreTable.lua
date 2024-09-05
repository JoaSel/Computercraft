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
            print("Adding remove key: " .. key)
            table.insert(toRemove, key)
        end
    end

    for _, deleteKey in pairs(toRemove) do
        print("removing key: " .. deleteKey)
        print(table.remove(t, deleteKey))
    end

    for key, value in pairs(t) do
        print(key .. tostring(value))
    end

    return #toRemove
end

local function length(t)
    local ret = 0
    for _ in pairs(t) do
        ret = ret + 1
    end
    return ret
end

local function firstOrDefault(t, predicate)
    for _, value in pairs(t) do
        if(predicate(value)) then
            return value
        end
    end

    return nil
end

local function forEach(t, func)
    for _, value in pairs(t) do
        func(value)
    end
end

return {  find = find, findKey = findKey, removeAll = removeAll, length = length, firstOrDefault = firstOrDefault, forEach = forEach }