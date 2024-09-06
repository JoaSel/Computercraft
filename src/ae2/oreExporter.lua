--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/oreExporter.lua

local meExporter = require("libs.meExporter")

local function filterFunc(item)
    for _, tag in pairs(item.tags) do
        if(tag == "minecraft:item/forge:raw_materials") then
            return true
        end
    end
    return false
end

meExporter.create(filterFunc, true)
meExporter.run()