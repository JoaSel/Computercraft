--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/gtceu/machineServer.lua true

package.path = package.path .. ";../../../?.lua"
package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")

local sendChannel = 43
local ackChannel = 44

local modem = pWrapper.find("modem")
local monitor = pWrapper.find("monitor")
local basalt = require("basalt")

local machines = {}

local main = basalt.addMonitor()
main:setMonitor(monitor)

-- local button = main
--         :addButton()
--         :setPosition(4, 4)
--         :setText("Click me!")
--         :onClick(
--             function()
--                 basalt.debug("I got clicked!")
--             end)

local flex = main:addFlexbox():setWrap("wrap"):setBackground(colors.lightGray):setPosition(1, 1):setSize("parent.w", "parent.h")

flex:addLabel():setSize("parent.w/2", 10):setText("Test!")

flex:addLabel():setSize("parent.w/2", 10):setText("Test!")

flex:addLabel():setSize("parent.w/2", 10):setText("Test!")

local function handleMessages()
  local event, side, channel, replyChannel, message, distance
  print("started")
  local sortFunc = function(a, b)
    return a.machineName > b.machineName
  end

  while (true) do
    event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    if (channel == sendChannel and message.machineName) then
      local exists = machines[message.machineName]
      if (exists) then
        machines[message.machineName].machineData = message
      else
        machines[message.machineName] = { machineData = message }
        print("New machine, sorting")
        table.sort(machines, sortFunc)
      end
    end
  end
end

main:addThread():start(handleMessages)

basalt.autoUpdate();
-- {
--   recipeLogic = {
--     fuelMaxTime = 0,
--     status = "IDLE",
--     duration = 0,
--     progress = 0,
--     fuelTime = 0,
--     isActive = 0,
--     totalContinuousRunningTime = 0,
--   },
--   isFormed = 1,
--   ForgeCaps = {},
--   cover = {},
--   activeRecipeType = 0,
--   isFlipped = 0,
--   paintingColor = -1,
--   isMuffled = 0,
-- }


-- {
--   recipeLogic = {
--     duration = 750,
--     status = "WORKING",
--     fuelMaxTime = 0,
--     progress = 128,
--     fuelTime = 0,
--     isActive = 1,
--     totalContinuousRunningTime = 128,
--   },
--   isFormed = 1,
--   ForgeCaps = {},
--   cover = {},
--   activeRecipeType = 0,
--   isFlipped = 0,
--   paintingColor = -1,
--   isMuffled = 0,
-- }