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

local function getRequestData()
    local requestDataLocationFile = fs.open("requestDataLocation", "r")
    local requestDataLocation = requestDataLocationFile.readLine()
    requestDataLocationFile.close()
    
    local socket = http.get(requestDataLocation)
    local content = socket.readAll()
    socket.close()
 
    if(not content) then
        error("Could not get request data.")
    end
    local parsed = textutils.unserialize(content)
    if(not parsed) then
        error("Could not unserialize request data.")
    end
 
    return parsed 
end

local function updateFile(url, filename)
    if(fs.exists(filename)) then
        local backupFilename = filename .. ".bak"
        print("Backing up " .. filename .. " => " .. backupFilename)
        fs.move(filename, backupFilename)
    end

    local socket = http.get(url)
    local content = socket.readAll()
    socket.close()

    local file = fs.open(filename, "w")
    file.write(content)
    file.close()
    -- local requestDataLocationFile = fs.open("requestDataLocation", "r")
    -- local requestDataLocation = requestDataLocationFile.readLine()
    -- requestDataLocationFile.close()
    
    
end

local function installGitClone()
    print("Installing SquidDev's git clone...")
    updateFile("https://gist.githubusercontent.com/SquidDev/e0f82765bfdefd48b0b15a5c06c0603b/raw/clone.min.lua", "clone.lua")
end

installGitClone()

print("Installing " .. scriptName .. " from " .. repoName)


print(scriptName)

