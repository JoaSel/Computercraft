--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/forbiddenAndArcanus/hephaestusForge.lua

package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")
local mTerm = require("moreTerm")
local dump = require("dump")

local forge = pWrapper.wrap("modularrouters:modular_router_1")
local forgeReader = pWrapper.find("blockReader")

print(forge.name)