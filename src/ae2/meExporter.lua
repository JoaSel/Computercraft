--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meExporter.lua

local meExporter = require("libs.meItemExporter")

local function filterFunc(item)
    return item.name == "cataclysm:athame"
end

meExporter.create(filterFunc, true, true)
meExporter.run()