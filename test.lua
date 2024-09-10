--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua test.lua

package.path = package.path .. ";./src/core/?.lua"

local jGui = require("jGui")
local dump = require("dump")

local x = peripheral.wrap("back")

dump.toTerm(os.pullEvent())