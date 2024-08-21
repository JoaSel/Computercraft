--wget run https://raw.githubusercontent.com/JoaSel/Computercraft/main/install.lua <fileName>
--https://cloud-catcher.squiddev.cc/

local args = { ... }

if(#args ~= 1) then
    error("Usage: ....")
end

local gitUrl = "https://github.com/JoaSel/"
local repoName = "Computercraft"
local scriptName = args[1]

print("Installing SquidDev's git clone...")
shell.run("wget", "https://gist.githubusercontent.com/SquidDev/e0f82765bfdefd48b0b15a5c06c0603b/raw/clone.min.lua", "clone.lua")

print("Creating startup file...")
local startupFile = fs.open("startup", "w+")

startupFile.writeLine(string.format("local scriptName = \"%s\"", scriptName))
startupFile.writeLine(string.format("local repoName = \"%s\"", repoName))
startupFile.writeLine(string.format("local repoBakName = \"%s\"", repoName .. "Bak"))
startupFile.writeLine(string.format("local gitUrl = \"%s\"", gitUrl))

startupFile.writeLine("shell.run(\"rm\", repoBakName)")
startupFile.writeLine("shell.run(\"mv\", repoName, repoBakName)")
startupFile.writeLine("if(not shell.run(\"clone.lua\", gitUrl .. repoName) and fs.exists(repoBakName)) then")
startupFile.writeLine("shell.run(\"mv\", repoBakName, repoName)")
startupFile.writeLine("end")

startupFile.writeLine("shell.run(repoName .. \"/\" .. scriptName)")
startupFile.close()

shell.run("startup")
