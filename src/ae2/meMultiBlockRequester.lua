--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meMultiBlockRequester.lua

package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")
local dump = require("dump")

local chest = pWrapper.find("minecraft:chest")
local nbtStorage = pWrapper.find("blockReader")

local blockData = nbtStorage.getBlockData()

local inTags = blockData.Items[1].tag["in"]

local function getRequiredItems(inTags)
	local ret = {}

	for _, item in pairs(inTags) do
		if(item.id) then
			ret[item.id] = (ret[item.id] or 0) + item["#"]
		end
	end

	return ret
end


dump.easy(getRequiredItems(inTags))


