--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/gtceu/machineServer.lua

package.path = package.path .. ";../core/?.lua"

local dump = require("dump")
local pWrapper = require("peripheralWrapper")
local gtceuIO = require("libs.gtceuIO")

local modem = pWrapper.find("modem")
modem.open(43) -- Open 43 so we can receive replies

local event, side, channel, replyChannel, message, distance

--while (true) do
  event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
  if(channel == 43) then
    if(message.recipeLogic.lastRecipe) then
      dump.toPastebin(message)
    end
  end
--end


--lastRecipe
--lastOriginRecipe