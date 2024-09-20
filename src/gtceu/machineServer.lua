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

local root = {}

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

local categoryFrame = main
    :addFlexbox()
    :setForeground(colors.white)
    :setBackground(colors.black)
    :setWrap("wrap")
    :setPosition(1, 2)
    :setSize("parent.w", "parent.h - 1")

local function getOrAddCategory(category)
  if (not root[category]) then
    root[category] = {}

    root[category].frame = main
        :addFlexbox()
        :setForeground(colors.white)
        :setBackground(colors.black)
        :setWrap("wrap")
        :setPosition(1, 2)
        :setSize("parent.w", "parent.h - 1")
        :hide()

    root[category].frame
      :addLabel()
      :setSize("parent.w", "2")
      :setTextAlign("center")
      :setText(category)
      :onClick(function ()
        root[category].frame:hide()
        categoryFrame:show()
      end)

    root[category].buttonFrame = categoryFrame
        :addLabel()
        :setBackground(colors.blue)
        :setSize("parent.w/2 - 1", 2)
        :setText(category)
        :setTextAlign("center")
        :onClick(function ()
          categoryFrame:hide()
          root[category].frame:show()
        end)

    root[category].machines = {}
  end

  return root[category]
end

local function getOrAddMachine(machineData)
  local category = getOrAddCategory(machineData.machineCategory)

  local exists = category.machines[machineData.machineName]
  if (exists) then
    exists.machineData = machineData
  else
    print("New machine")
    category.machines[machineData.machineName] = { machineData = machineData }
    category.machines[machineData.machineName].displayFrame = category.frame
        :addFrame()
        :setSize("parent.w/2 - 1", 2)
        :setTextAlign("center")

    category.machines[machineData.machineName].displayFrame
        :addLabel()
        :setTextAlign("center")
        :setText(machineData.machineName)
  end

  return category.machines[machineData.machineName]
end

local function updateMachine(machineData)
  local machine = getOrAddMachine(machineData)

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

  machine.displayFrame
    :setBackground(displayColor)
    --:editItem(2, errorStatus or string.format(" Status: OK (%s)", machineData.blockData.recipeLogic.status))
end

local function handleMessages()
  local event, side, channel, replyChannel, message, distance
  print("Started listening on " .. sendChannel)
  modem.open(sendChannel)

  while (true) do
    event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    if (channel == sendChannel and message.machineCategory) then
      updateMachine(message)
    end
  end
end



main:addThread():start(handleMessages)

basalt.autoUpdate();

-- local flex = main
--     :addFlexbox()
--     :setForeground(colors.white)
--     :setBackground(colors.black)
--     :setWrap("wrap")
--     :setPosition(1, 2)
--     :setSize("parent.w", "parent.h - 1")
--     :hide()

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
