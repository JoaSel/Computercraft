--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/oreExporter.lua

local meExporter = require("libs.meExporter")

local function filterFunc(item)
    return item.name == "gtceu:raw_neodymium"
end

meExporter.create(filterFunc)
meExporter.run()