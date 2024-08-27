--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua src/gtceu/machineReader.lua

package.path = package.path .. ";../core/?.lua"

local dump = require("dump")
local pWrapper = require("peripheralWrapper")
local gtceuIO = require("libs.gtceuIO")

local modem = pWrapper.find("modem")
modem.open(43) -- Open 43 so we can receive replies

-- Send our message
modem.transmit(15, 43, "Hello, world!")

-- And wait for a reply
local event, side, channel, replyChannel, message, distance
repeat
  event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
until channel == 43

print("Received a reply: " .. tostring(message))