---@diagnostic disable: need-check-nil

package.path = package.path .. ";../core/?.lua"

local dump = require("dump")
local mTable = require("moreTable")
local pWrapper = require("peripheralWrapper")

local _input = nil
local _destinations = nil

local _onlyEmpty = false

local _verbose = false

local destinationI = 1

local function create(input, destinationType, onlyEmpty, verbose)
	_input = pWrapper.wrap(input)
	_destinations = { pWrapper.find(destinationType) }

	mTable.removeAll(_destinations, function(d)
		return d.name == _input.name
	end)

	_onlyEmpty = onlyEmpty

	_verbose = verbose

	print(string.format("Setup evenSplitter with %d outputs.", #_destinations))
end

local function trySend(items, fluids, destination)
	local sendItemsCount = #items
	local sendFluidsCount = #fluids

	local destinationItemsCount = #destination.list()
	local destinationFluidsCount = #destination.tanks()
	local itemSpaceLeft = destination.size() - destinationItemsCount

	if (_onlyEmpty and ((sendItemsCount > 0 and destinationItemsCount > 0) or (sendFluidsCount > 0 and destinationFluidsCount > 0))) then
		return false
	elseif ((sendItemsCount > 0 and itemSpaceLeft < sendItemsCount) or (sendFluidsCount > 0 and destinationFluidsCount > 0)) then
		return false
	end

	for slot, _ in pairs(items) do
		_input.pushItems(destination.name, slot)
	end

	dump.easy(_input.tanks())
	while #_input.tanks() > 0 do
		_input.pushFluid(destination.name)
	end

	return true
end

local function send(items, fluids)
	repeat
		local destination = _destinations[destinationI]

		if (_verbose) then
			print("Trying to send to " .. destination.name)
		end
		local success = trySend(items, fluids, destination)

		destinationI = (destinationI % #_destinations) + 1
	until success
end

local function run()
	print("Starting to split!")
	--while (true) do
		local items = _input.list()
		local fluids = _input.tanks()

		if (#items > 0 or #fluids > 0) then
			print("sending")
			send(items, fluids)
		else
			--os.sleep(2)
		end
	--end
end



return { create = create, run = run }
