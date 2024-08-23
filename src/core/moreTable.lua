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

return {  find, findKey }