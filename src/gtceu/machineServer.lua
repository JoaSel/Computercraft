--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/gtceu/machineServer.lua

package.path = package.path .. ";../core/?.lua"

-- local dump = require("dump")
-- local pWrapper = require("peripheralWrapper")
-- local gtceuIO = require("libs.gtceuIO")
-- local mMon = require("moreMonitor")
-- local time = require("time")

-- local sendChannel = 43
-- local ackChannel = 44

-- local modem = pWrapper.find("modem")
-- local monitor = pWrapper.find("monitor")

-- modem.open(sendChannel)
-- mMon.setMonitor(monitor, 0.5)

-- local machines = {}

-- local function render()
--   while (true) do
--     mMon.reset()

--     for _, machine in pairs(machines) do
--       mMon.writeLine(machine.machineName)
--     end

--     os.sleep(1)
--   end
-- end

-- local function handleMessages()
--   local event, side, channel, replyChannel, message, distance
--   print("started")
--   local sortFunc = function (a, b)
--     return a.machineName > b.machineName
--   end

--   while (true) do
--     event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

--     -- mMon.reset()
--     -- mMon.writeLine(time.getTime())
--     -- mMon.newLine()
--     -- mMon.writeLine(dump.text(message))
--     print("Got message")

--     if(channel == sendChannel and message.machineName) then
--       local exists = machines[message.machineName]
--       machines[message.machineName] = message

--       if(not exists) then
--         print("new machine, sorting")
--         table.sort(machines, sortFunc)
--       end
--      end
--   end
-- end


local basalt = require("basalt")

local main = basalt.createFrame()
local button = main --> Basalt returns an instance of the object on most methods, to make use of "call-chaining"
        :addButton() --> This is an example of call chaining
        :setPosition(4, 4)
        :setText("Click me!")
        :onClick(
            function()
                basalt.debug("I got clicked!")
            end)

basalt.autoUpdate()


-- parallel.waitForAny(
-- 	render,
-- 	handleMessages
-- )




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