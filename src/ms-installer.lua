--[[
    An installation script that manages installing all movescript libraries easily.
]]--

local libs = {
    "movescript.lua",
    "itemscript.lua",
    "buildscript.lua"
}

local BASE_URL = "https://andrewlalis.github.io/movescript/scripts/"

print("Running Movescript installer")
print("----------------------------")
for _, lib in pairs(libs) do
    if fs.exists(lib) then
        fs.delete(lib)
        print("Deleted " .. lib)
    end
    local success = shell.run("wget", BASE_URL .. lib)
    if not success then
        error("Failed to install " .. lib)
    end
    print("Downloaded " .. lib)
end
print("----------------------------")
for _, lib in pairs(libs) do
    local nameIdx = string.find(lib, "%.")
    local name = string.sub(lib, nameIdx - 1, -1)
    local m = require(name)
    print("  " .. lib .. " installed with version " .. m.VERSION)
end
print("Done!")
