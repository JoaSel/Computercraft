local args = { ... }

--Create startup file that does
    --mv old repo file
    --get a github repo
    --*if it failed mv back

if(#args ~= 1) then
    error("Usage: ....")
end

local repoName = "https://github.com/JoaSel/Computercraft"
local scriptName = args[1]

local function updateFile(url, filename)
    local backupFilename = filename .. ".bak"
    if(fs.exists(filename)) then
        print("Backing up " .. filename .. " => " .. backupFilename)
        fs.move(filename, backupFilename)
    end

    local socket = http.get(url)
    if(socket == nil) then
        print("Error getting " .. url)
        if(fs.exists(backupFilename)) then
            print("Restoring old version.")
            fs.move(backupFilename, filename)
        else
            print("Could not find " .. url)
        end
    end

    local content = socket.readAll()
    socket.close()

    local file = fs.open(filename, "w")
    file.write(content)
    file.close()

    if(fs.exists(backupFilename)) then
        fs.delete(backupFilename)
    end
end

print("Installing SquidDev's git clone...")
updateFile("https://gist.githubusercontent.com/SquidDev/e0f82765bfdefd48b0b15a5c06c0603b/raw/clone.min.lua2", "clone.lua")

print("Installing " .. scriptName .. " from " .. repoName)


print(scriptName)

