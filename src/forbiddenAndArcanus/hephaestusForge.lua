--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/forbiddenAndArcanus/hephaestusForge.lua

package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")
local mTerm = require("moreTerm")
local dump = require("dump")

local input = pWrapper.find("minecraft:chest")

local forge = pWrapper.wrap("modularrouters:modular_router_1")
local forgeReader = pWrapper.find("blockReader")

local pedestal1 = pWrapper.wrap("modularrouters:modular_router_2")
local pedestal2 = pWrapper.wrap("modularrouters:modular_router_3")
local pedestal3 = pWrapper.wrap("modularrouters:modular_router_4")
local pedestal4 = pWrapper.wrap("modularrouters:modular_router_5")

dump.toPastebin(forgeReader.getBlockData())