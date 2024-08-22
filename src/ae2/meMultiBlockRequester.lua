--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/meMultiBlockRequester.lua

package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")
local dump = require("dump")

local chest = pWrapper.find("minecraft:chest")
local reader = pWrapper.find("blockReader")

local blockData = reader.getBlockData()

local function getRequiredItems(inTags)
	local ret = {}

	for _, item in pairs(inTags) do
		if(item.id) then
			ret[item.id] = (ret[item.id] or 0) + item["#"]
		end
	end

	return ret
end

local function adjustExistingItems(requiredItems)
	local existing = chest.list()

	for _, item in pairs(existing) do
		if(requiredItems[item.name] ~= nil) then
			requiredItems[item.name] = requiredItems[item.name] - item.count
		end
	end
end

print("Press Enter to run.")
--local x = io.read()
local firstItem = blockData.Items[1]
if(not firstItem) then
	dump.easy(firstItem)
	print("No pattern found!")
end
local inTags = firstItem.tag["in"]

local requiredItems = getRequiredItems(inTags)
adjustExistingItems(requiredItems)

dump.easy(requiredItems)


