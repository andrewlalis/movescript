--[[
Installation script for installing all libraries.

Run `wget run https://github.com/andrewlalis/movescript/blob/main/install.lua`
to run the installer on your device.
]]--

BASE_URL = "https://github.com/andrewlalis/movescript/blob/main"

SCRIPTS = {
    "movescript.lua",
    "itemscript.lua"
}

-- Create a local executable to re-install, instead of having to run this file via wget.
local f = io.open("install-movescript.lua", "w")
for _, script in pairs(SCRIPTS) do
    url = BASE_URL .. "/" .. script
    cmd = "wget " .. url .. " " .. script
    shell.run(cmd)
    f:write("shell.run(\"" .. cmd .. "\")")
end
f:close()
