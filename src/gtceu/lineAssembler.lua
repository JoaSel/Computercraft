--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/gtceu/lineAssembler.lua

package.path = package.path .. ";../debug/?.lua"

local debug = require("src.core.dump")

print(debug)
debug.printDump({name = "test"})

