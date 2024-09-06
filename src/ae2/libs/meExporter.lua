---@diagnostic disable: need-check-nil

package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")

local meBridge = pWrapper.find("meBridge")

local _verbose = false

local function create()
	print("meExporter created.")
end

local function run()
end


return { create = create, run = run }
