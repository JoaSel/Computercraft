--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/ae2/dislocator.lua true

package.path = package.path .. ";../../../?.lua"
package.path = package.path .. ";../core/?.lua"

local pWrapper = require("peripheralWrapper")

local basalt = require("basalt")
local mTable = require("moreTable")
local mString = require("moreString")
local dump = require("dump")

local monitor = pWrapper.find("monitor")

local inventory = pWrapper.find("dankstorage:dank_tile")
local playerInventory = pWrapper.find("inventoryManager")
local playerDetector = pWrapper.find("playerDetector")

monitor.setTextScale(0.5)

local root = {}
root.children = {}

local main = basalt.addMonitor()
    :setForeground(colors.white)
    :setBackground(colors.black)
    :setMonitor(monitor)

root.frame = main
    :addFlexbox()
    :setForeground(colors.white)
    :setBackground(colors.black)
    :setWrap("wrap")
    :setPosition(1, 2)
    :setSize("parent.w", "parent.h - 1")

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

local function getDistance(x1, x2, y1, y2, z1, z2)
  return math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2) + math.pow(z2 - z1, 2))
end

local function createCategoryFrames(dislocators)
  for _, dislocator in pairs(dislocators) do
    local categoryId = splitDisplayName(dislocator.displayName)
    if (not root.children[categoryId]) then
      print("Adding category: " .. categoryId)
      root.children[categoryId] = {}

      local currCategory = root.children[categoryId]

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
            root.frame:show()
          end)

      currCategory.miniFrame = root.frame
          :addFrame()
          :setBackground(colors.blue)
          :setSize("parent.w/2 - 1", 2)
          :onClick(function()
            root.frame:hide()
            currCategory.frame:show()
          end)

      currCategory.miniFrame
          :addLabel()
          :setText(" " .. categoryId)

      currCategory.childCountLabel = currCategory.miniFrame
          :addLabel()
          :setText(currCategory.childCount)
          :setPosition(1, 2)
    end
  end
end

local function fixPositions(t)
  local keys = {}
  for k, _ in pairs(t.children) do
    table.insert(keys, k)
  end


  table.sort(keys, function(a, b)
    return a < b
  end)

  for i, key in pairs(keys) do
    local child = t.children[key]

    local xPos = i % 2 == 0 and "parent.w/2 + 1" or 0
    local yPos = math.floor((i - 1) / 2) * 3 + 4
    local color = math.floor((i - 1) / 2) % 2 == 0 and colors.blue or colors.cyan

    child.miniFrame
      :setPosition(xPos, yPos)
      :setBackground(color)
  end
end

local function sleepUntilPlayerMoved()
  local oldPos = playerDetector.getPlayerPos("EvilKurt2")
  for i = 1, 50, 1 do
    local newPos = playerDetector.getPlayerPos("EvilKurt2")

    if(getDistance(newPos.x, oldPos.x, newPos.y, oldPos.y, newPos.z, oldPos.z) > 10) then
      return
    end

    sleep(0.2)
  end
end

local function createDestinationFrames(dislocators)
  for slot, dislocator in pairs(dislocators) do
    local categoryId, name = splitDisplayName(dislocator.displayName)

    local category = root.children[categoryId]

    if (not category.children) then
      category.children = {}
    end

    category.children[name] = {}

    local currChild = category.children[name]

    currChild.miniFrame = category.frame
        :addLabel()
        :setForeground(colors.black)
        :setBackground(colors.blue)
        :setSize("parent.w/2 - 1", 2)
        :setText(name)
        :setTextAlign("center")
        :onClick(function()
          playerInventory.addItemToPlayer("up", { name = "draconicevolution:dislocator", count = 1, toSlot = 36, fromSlot = slot - 1 })
          sleepUntilPlayerMoved()
          playerInventory.removeItemFromPlayer("up", { name = "draconicevolution:dislocator", count = 1, toSlot = slot - 1, fromSlot = 36 })
        end)

    -- currChild.miniFrame
    --     :addLabel()
    --     :setPosition(2, 1)
    --     

    -- local desc = string.format("%d, %d, %d at %s", dislocator.nbt.tag.target.x, dislocator.nbt.tag.target.y,
    --   dislocator.nbt.tag.target.z, translate[dislocator.nbt.tag.target.dim] or dislocator.nbt.tag.target.dim)

    -- currChild.statusLabel = currChild.miniFrame
    --     :addLabel()
    --     :setPosition(1, 2)
    --     :setText("")

    category.childCount   = category.childCount + 1
    category.childCountLabel
        :setText(category.childCount .. " Destinations")
  end
end
local function initialize()
  local allItems = inventory.list()
  local dislocators = {}

  for slot, item in pairs(allItems) do
    if(item.name == "draconicevolution:dislocator") then
      dislocators[slot] = inventory.getItemDetail(slot)
    end
  end

  createCategoryFrames(dislocators)
  createDestinationFrames(dislocators)

  fixPositions(root)
  for _, category in pairs(root.children) do
    fixPositions(category)
  end
end

initialize()

basalt.autoUpdate();
