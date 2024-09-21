--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/dislocator.lua true

package.path = package.path .. ";../../../?.lua"
package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")

local basalt = require("basalt")
local mString = require("moreString")
local dump = require("dump")


local monitor = pWrapper.find("monitor")

local bridge = pWrapper.find("meBridge")
local playerInventory = pWrapper.find("inventoryManager")

monitor.setTextScale(0.5)

local root = {}

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

local function sortFrames(category)
  print("Sorting")

  local keyset = {}
  for k, _ in pairs(category.machines) do
    table.insert(keyset, k)
  end

  table.sort(keyset, function (a, b)
    return a < b
  end)

  for i, key in pairs(keyset) do
    local machine = category.machines[key]

    local xPos = i % 2 == 0 and "parent.w/2 + 1" or 0
    local yPos = math.floor((i - 1) / 2) * 3 + 4

    machine.miniFrame:setPosition(xPos, yPos)
  end
end

local function getOrAddCategory(category)
  if (not root[category]) then
    root[category] = {}

    local currCategory = root[category]

    currCategory.machineCount = 0

    currCategory.frame = main
        :addFrame()
        :setForeground(colors.white)
        :setBackground(colors.black)
        :setPosition(1, 1)
        :setSize("parent.w", "parent.h")
        :hide()

    currCategory.frame
        :addLabel()
        :setSize("parent.w", "2")
        :setTextAlign("center")
        :setText(category)
        :onClick(function()
          currCategory.frame:hide()
          categoryFrame:show()
        end)

    currCategory.miniFrame = categoryFrame
        :addFrame()
        :setBackground(colors.blue)
        :setSize("parent.w/2 - 1", 2)
        :onClick(function()
          sortFrames(currCategory)
          categoryFrame:hide()
          currCategory.frame:show()
        end)

    currCategory.miniFrame
        :addLabel()
        :setText(category)

    currCategory.machineCountLabel = currCategory.miniFrame
        :addLabel()
        :setText(currCategory.machineCount)
        :setPosition(1, 2)

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

    local currMachine = category.machines[machineData.machineName]

    local xPos = category.machineCount % 2 == 0 and "parent.w/2 + 1" or 0
    local yPos = math.floor((category.machineCount - 1) / 2) * 3 + 4

    currMachine.miniFrame = category.frame
        :addFrame()
        :setSize("parent.w/2 - 1", 2)
        :setPosition(xPos, yPos)
        :onClick(function ()
          print("clicked machine")
        end)

    currMachine.miniFrame
        :addLabel()
        :setPosition(2, 1)
        :setText(machineData.machineName)

    currMachine.statusLabel = currMachine.miniFrame
        :addLabel()
        :setPosition(1, 2)
        :setText("Initialized")

    category.machineCountLabel
        :setText(category.machineCount)
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

  machine.miniFrame
      :setBackground(displayColor)

  machine.statusLabel
      :setText(errorStatus or string.format(" Status: OK (%s)", machineData.blockData.recipeLogic.status))
end

local function initialize()
  local dislocators = bridge.listItems({ name = "draconicevolution:dislocator"})

  local t1, t2 = next(dislocators)

  dump.toTerm(t2)
  
  for _, dislocator in pairs(dislocators) do
    
    --dump.shallow(dislocator)
  end
end

initialize()

basalt.autoUpdate();
