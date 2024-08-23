---@diagnostic disable: need-check-nil

package.path = package.path .. ";../core/?.lua"

local mTable = require("moreTable")
local pWrapper = require("peripheralWrapper")

local _input = nil
local _destinations = nil

local _verbose = false

local destinationI = 1

local function create(input, destinationType, verbose)
	_input = pWrapper.wrap(input)
	_destinations = { pWrapper.find(destinationType) }

	mTable.removeAll(_destinations, function (d)
		return d.name == _input.name
	end)

	_verbose = verbose

	if(_verbose) then
		print(string.format("Setup evenSplitter with %d outputs.", #_destinations))
	end
end

local function trySend(items, destination)
	local spaceLeft = destination.size() - #destination.list()
	if (spaceLeft < #items) then
		return false
	end

	for slot, _ in pairs(items) do
		_input.pushItems(destination.name, slot)
	end

	return true
end

local function send(items)
	repeat
		local destination = _destinations[destinationI]

		if(_verbose) then
			print("Trying to send to " .. destination.name)
		end
		local success = trySend(items, destination)

		destinationI = (destinationI % #_destinations) + 1
	until success
end

local function run()
	while (true) do
		local items = _input.list()
		if (#items > 0) then
			send(items)
		else
			os.sleep(2)
		end
	end
end



return { create = create, run = run, hasTag = hasTag }
