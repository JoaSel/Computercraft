--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/dislocator.lua true

package.path = package.path .. ";../../../?.lua"
package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")

local basalt = require("basalt")
local mTable = require("moreTable")
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

  table.sort(keyset, function(a, b)
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

    currCategory.childCount = 0

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

    currCategory.childCountLabel = currCategory.miniFrame
        :addLabel()
        :setText(currCategory.childCount)
        :setPosition(1, 2)

    currCategory.children = {}
  end

  return root[category]
end

local function addDislocator(dislocator)


  local category = getOrAddCategory(categoryId)

  category.childCount = category.childCount + 1
  category.children[nameId] = { }

  local currChild = category.children[nameId]

  local xPos = category.childCount % 2 == 0 and "parent.w/2 + 1" or 0
  local yPos = math.floor((category.childCount - 1) / 2) * 3 + 4

  currChild.miniFrame = category.frame
      :addFrame()
      :setSize("parent.w/2 - 1", 2)
      :setPosition(xPos, yPos)
      :onClick(function()
        print("clicked machine")
      end)

    currChild.miniFrame
      :addLabel()
      :setPosition(2, 1)
      :setText("testing")

    currChild.statusLabel = currChild.miniFrame
      :addLabel()
      :setPosition(1, 2)
      :setText("Initialized")

  category.childCountLabel
      :setText(category.childCount)
end

local function splitDisplayName(displayName)
  local category
  local name

  local split = mString.split(displayName, "-")
  if (#split == 1) then
    category = "Unkown"
    name = split[1]
  else
    category = split[1]
    name = split[2]
  end

  return category, name
end

local function createCategoryFrames(dislocators)
  for _, dislocator in pairs(dislocators) do
    local categoryId = splitDisplayName(dislocator.displayName)
    if (not root[categoryId]) then
      print("Adding category: " .. categoryId)
      root[categoryId] = {}

      local currCategory = root[categoryId]

      currCategory.childCount = 0

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
          :setText(categoryId)
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
          :setText(categoryId)

      currCategory.childCountLabel = currCategory.miniFrame
          :addLabel()
          :setText(currCategory.childCount)
          :setPosition(1, 2)
    end
  end
end

local function initialize()
  local allItems = bridge.listItems({ name = "draconicevolution:dislocator" })

  local dislocators = mTable.where(allItems, function(d)
    return d.name == "draconicevolution:dislocator" and d.displayName ~= "Dislocator"
  end)

  createCategoryFrames(dislocators)

  for _, dislocator in pairs(dislocators) do
    addDislocator(dislocator)
  end
end

initialize()

basalt.autoUpdate();
