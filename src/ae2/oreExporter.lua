--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/oreExporter.lua

local meExporter = require("libs.meExporter")

local function filterFunc(item)
    return item.tags["minecraft:item/forge:raw_materials"]
end

meExporter.create(filterFunc, true)
meExporter.run()