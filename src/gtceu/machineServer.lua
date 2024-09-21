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
    :setMonitor(monitor)

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

    local currCategory = root[category]

    currCategory.machineCount = 0

    currCategory.frame = main
        :addFlexbox()
        :setForeground(colors.white)
        :setBackground(colors.black)
        :setWrap("wrap")
        :setPosition(1, 2)
        :setSize("parent.w", "parent.h - 1")
        :hide()

    currCategory.frame
      :addLabel()
      :setSize("parent.w", "2")
      :setTextAlign("center")
      :setText(category)
      :onClick(function ()
        currCategory.frame:hide()
        categoryFrame:show()
      end)

    currCategory.buttonFrame = categoryFrame
        :addFrame()
        :setBackground(colors.blue)
        :setSize("parent.w/2 - 1", 2)
        :onClick(function ()
          if(not currCategory.sorted) then
            table.sort(currCategory.machines, function (a, b)
              return a.machineName > b.machineName
            end)
            currCategory.sorted = true
          end
          categoryFrame:hide()
          currCategory.frame:show()
        end)

      currCategory.buttonFrame
        :addLabel()
        :setText(category)
        :setTextAlign("center")

    currCategory.machines = {}
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
    category.machineCount = category.machineCount + 1

    category.machines[machineData.machineName] = { machineData = machineData }
    category.machines[machineData.machineName].displayFrame = category.frame
        :addFrame()
        :setSize("parent.w/2 - 1", 2)

    category.machines[machineData.machineName].displayFrame
        :addLabel()
        :setText(machineData.machineName)

    category.machines[machineData.machineName].statusLabel = category.machines[machineData.machineName].displayFrame
        :addLabel()
        :setPosition(1, 2)
        :setText("Initialized")
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

  machine.statusLabel
    :setText(errorStatus or string.format(" Status: OK (%s)", machineData.blockData.recipeLogic.status))
end

local function handleMessages()
  local event, side, channel, replyChannel, message, distance
  print("Started listening on " .. sendChannel)
  modem.open(sendChannel)

  local i = 1

  while (true) do
    event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    if (channel == sendChannel and message.machineCategory) then
      updateMachine(message)
    else
      print(message.machineId)
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
