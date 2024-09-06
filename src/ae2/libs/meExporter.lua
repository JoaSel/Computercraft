
---@diagnostic disable: need-check-nil

package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")
local dump = require("dump")

local meBridge = pWrapper.find("meBridge")

local _verbose = false

local function create()
	local searchItem = {
		tags = {
			"forge:raw_materials"
		}
	}
	dump.toTerm(meBridge.getItem(searchItem))
	print("meExporter created.")
end

local function run()
end


return { create = create, run = run }
