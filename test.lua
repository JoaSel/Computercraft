--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua test.lua

local pWrapper = require("src.core.peripheralWrapper")
local dump = require("src.core.dump")

local x = pWrapper.find("blockReader")

dump.easy(x.getBlockData())