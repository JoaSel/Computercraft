--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/logistics/blastFurnaceSplitter.lua
local evenSplitter = require("libs.evenSplitter")

local input = "entangled:tile_29"
local destinationType = "entangled:tile"

evenSplitter.create(input, destinationType, true, true)
evenSplitter.run()