---@diagnostic disable: need-check-nil

package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")
local mTable = require("moreTable")
local dump = require("dump")

local meBridge = pWrapper.find("meBridge")

local _direction = "top"
local _sleepTime = 5
local _filterFunc = nil
local _randomMode = false

local _verbose = false

local function create(filterFunc, randomMode)
	_filterFunc = filterFunc
	_randomMode = randomMode

	print("meExporter created.")
end

local function getRelevantItems()
	return mTable.where(meBridge.listItems(), _filterFunc)
end

local function run()
	local i = 1
	local itemsToExport = getRelevantItems()

	print(string.format("Exporting %s types of items.", #itemsToExport))
	while true do
		if(i % 20 == 0) then
			itemsToExport = getRelevantItems()
		end

		if(mTable.length(itemsToExport) == 0) then
			error("Found no valid items")
		end

		local itemToExport = nil
		if(_randomMode) then
			itemToExport = itemsToExport[ math.random(#itemsToExport) ]
		else
			itemToExport = itemsToExport[1]
		end

		meBridge.exportItem(itemToExport, _direction)

		i = i + 1
		os.sleep(5)
	end
end


return { create = create, run = run }


-- {
-- 	tags = {
-- 	  "minecraft:item/forge:raw_materials",
-- 	  "minecraft:item/forge:raw_materials/neodymium",
-- 	},
-- 	name = "gtceu:raw_neodymium",
-- 	amount = 1822851,
-- 	fingerprint = "91C35BE56CCEC42CD71B927AF2B8E7D0",
-- 	isCraftable = false,
-- 	nbt = {
-- 	  id = "gtceu:raw_neodymium",
-- 	},
-- 	displayName = "Raw Neodymium",
--   }