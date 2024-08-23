--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/logistics/blastFurnaceSplitter.lua
local evenSplitter = require("libs.evenSplitter")

local input = "entangled_tile_27"
local destinationType = "entangled_tile"

evenSplitter.create(input, destinationType, true)
evenSplitter.run()