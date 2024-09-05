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
  ["gtceu:alloy_blast_smelter"] = "Alloy Blast Smelter",
  ["gtceu:advanced_large_chemical_reactor"] = "Chemical Reactor"
}

local machines = {}

monitor.setTextScale(0.5)
local main = basalt.addMonitor()
  :setForeground(colors.white)
  :setBackground(colors.black)

main:setMonitor(monitor)

local flex = main
  :addFlexbox()
  :setForeground(colors.white)
  :setBackground(colors.black)
  :setWrap("wrap")
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
        machine.displayFrame = flex:addList():setSize("parent.w/2 - 1", 10)
      end

      local displayName = translations[machineData.machineName] or machineData.machineName

      machine.displayFrame:editItem(1, displayName)
      machine.displayFrame:editItem(2, "Status: OK")
      machine.displayFrame:editItem(3, machineData.recipeLogic.status, (machineData.recipeLogic.status == "WORKING" and colors.green or colors.orange) )
end

local function handleMessages()
  local event, side, channel, replyChannel, message, distance
  print("Started listening on " .. sendChannel)

  while (true) do
    event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    if (channel == sendChannel and message.machineId) then
      updateMachine(message)
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