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

local function installIfPossible(url, filename)

end

local function installGitClone()
    print("Installing SquidDev's git clone...")
    local x = shell.run("wget https://gist.githubusercontent.com/SquidDev/e0f82765bfdefd48b0b15a5c06c0603b/raw/clone.min.lua2")
    print(x)
end

installGitClone()

print("Installing " .. scriptName .. " from " .. repoName)


print(scriptName)

