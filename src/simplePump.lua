local input = peripheral.wrap("top")
local output = "bottom"

while(true) do
	for slot, fluid in pairs(input.tanks()) do
		input.pushFluid(output, nil, fluid.name)
	end
end