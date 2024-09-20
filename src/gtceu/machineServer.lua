--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/gtceu/machineServer.lua true

package.path = package.path .. ";../../../?.lua"
package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")

local basalt = require("basalt")
local mString = require("moreString")
local dump = require("dump")

local sendChannel = 43
local ackChannel = 44

local modem = pWrapper.find("modem", function(_, modem)
  return modem.isWireless()
end)
local monitor = pWrapper.find("monitor")

local allMachines = {}

local displayColors = {
  ["IDLE"] = colors.green,
  ["WAITING"] = colors.orange,
  ["WORKING"] = colors.orange,
  ["ERROR"] = colors.red,
}

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
    :setPosition(1, 2)
    :setSize("parent.w", "parent.h - 1")

local function updateMachine(machineData)
  local split = mString.split(machineData.machineId, "-")

  local machines
  local machineId
  if (#split == 1) then
    machines = allMachines["Unkown"]
    machineId = split[1]
  else
    machines = allMachines[split[1]]
    machineId = split[2]
  end

  print(machineId)
  local exists = machines[machineId]
  if (exists) then
    machines[machineId].machineData = machineData
  else
    print("New machine")
    machines[machineId] = { machineData = machineData }
  end
  local machine = machines[machineId]

  if (not machine.displayFrame) then
    machine.displayFrame = flex
        :addList()
        :setSize("parent.w/2 - 1", 2)
  end

  local displayColor = displayColors[machineData.blockData.recipeLogic.status]
  if (not displayColor) then
    error("Unkown status: " .. machineData.blockData.recipeLogic.statu)
  end

  local errorStatus
  if (machineData.blockData.recipeLogic.status == "IDLE" and (machineData.hasInputItems or machineData.hasInputFluids)) then
    if (machine.error) then
      displayColor = colors.red
      errorStatus = string.format(" Status: ERROR (%s)", machineData.blockData.recipeLogic.status)
    end
    machine.error = true
  else
    machine.error = false
  end

  machine.displayFrame:setBackground(displayColor)
  machine.displayFrame:editItem(1, " " .. machineData.machineId)
  machine.displayFrame:editItem(2,
    errorStatus or string.format(" Status: OK (%s)", machineData.blockData.recipeLogic.status))
end

local function handleMessages()
  local event, side, channel, replyChannel, message, distance
  print("Started listening on " .. sendChannel)
  modem.open(sendChannel)

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
