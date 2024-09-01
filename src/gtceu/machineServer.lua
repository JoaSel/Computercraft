--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/gtceu/machineServer.lua true

package.path = package.path .. ";../../../?.lua"
package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")

local sendChannel = 43
local ackChannel = 44

local modem = pWrapper.find("modem")
local monitor = pWrapper.find("monitor")
local basalt = require("basalt")

local translations = {
  ["gtceu:alloy_blast_smelter"] = "Alloy Blast Smelter"
}

local machines = {}

local main = basalt.addMonitor()
main:setMonitor(monitor)

local flex = main:addFlexbox()
  :setWrap("wrap")
  :setBackground(colors)
  :setPosition(1, 1)
  :setSize("parent.w", "parent.h")

local function updateMachine(machineData)
  local exists = machines[machineData.machineId]
      if (exists) then
        machines[machineData.machineId].machineData = machineData
      else
        print("New machine")
        machines[machineData.machineId] = { machineData = machineData }
      end
      local machine = machines[machineData.machineId]

      if(not machine.displayFrame) then
        machine.displayFrame = flex:addLabel():setSize("parent.w/2 - 1", 10)
      end

      machine.displayFrame:setText(machineData.machineName)
end

local function handleMessages()
  local event, side, channel, replyChannel, message, distance
  print("started")

  while (true) do
    event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    if (channel == sendChannel and message.machineId) then
      --updateMachine(message)
    end
  end
end



--main:addThread():start(handleMessages)

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