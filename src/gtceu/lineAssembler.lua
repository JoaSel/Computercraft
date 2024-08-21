--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/gtceu/lineAssembler.lua

package.path = package.path .. ";../debug/?.lua"

local debug = require("debug")

print(debug)
debug.printDump({name = "test"})

