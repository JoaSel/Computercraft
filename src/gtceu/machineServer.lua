--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/gtceu/machineServer.lua

package.path = package.path .. ";../core/?.lua"

local dump = require("dump")
local pWrapper = require("peripheralWrapper")
local gtceuIO = require("libs.gtceuIO")
local mMon = require("moreMonitor")

local sendChannel = 43
local ackChannel = 44

local modem = pWrapper.find("modem")
local monitor = pWrapper.find("monitor")

modem.open(sendChannel)
mMon.setMonitor(monitor)

local event, side, channel, replyChannel, message, distance

while (true) do
  event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
  if(channel == 43) then
    mMon.writeLine(os.time("utc"))
    mMon.newLine()
    mMon.writeLine(dump.text(message))
  end
end


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