---@diagnostic disable: need-check-nil

package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")
local mTable = require("moreTable")
local dump = require("dump")

local meBridge = pWrapper.find("meBridge")

local _filterFunc = nil
local _verbose = false

local function create(filterFunc)
	_filterFunc = filterFunc
	
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



		i = i + 1
		os.sleep(5)
	end
	local searchItem = {
		name = "gtceu:raw_neodymium",
		tags = {
			"forge:raw_materials"
		}
	}
	dump.toTerm()
end


return { create = create, run = run }
