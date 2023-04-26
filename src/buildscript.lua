--[[
Buildscript - A unified set of tools that make repetitive building tasks easier
with ComputerCraft robots.

Author: Andrew Lalis <andrewlalisofficial@gmail.com>

This module depends upon both Movescript and Itemscript.
]]--
local movescript = require("movescript")
local itemscript = require("itemscript")

-- The buildscript module.
local buildscript = {}
buildscript.VERSION = "0.0.1"

-- Runs a movescript script, while ensuring that a given item is always selected.
function buildscript.runWithItem(ms_script, filterExpr)
    local instructions = movescript.parse(ms_script)
    for idx, instruction in pairs(instructions) do
        itemscript.selectOrWait(filterExpr)
        movescript.executeInstruction(instruction)
    end
end

local function parseArgValue(argSpec, str)

end

-- Parses arguments according to a specification table, for common building
-- scripts, and returns a table with key-value pairs for each arg.
-- The specification table should be formatted like so:
-- {
--   argName = { type = "string", required = true, idx = 1 }
-- }
function buildscript.parseArgs(args, spec)
    local idxArgSpecs = {}
    local namedArgSpecs = {}
    for name, argSpec in pairs(spec) do
        if argSpec.idx ~= nil then
            -- Add this argSpec to the list of indexed arg specs for parsing first.
            if type(argSpec.idx) ~= "number" or argSpec.idx < 1 do
                return false, "Invalid argument specification: " .. name .. " does not have a valid numeric index."
            end
            idxArgSpecs[name] = argSpec
        elseif argSpec.name ~= nil then
            -- Otherwise, ensure that this argSpec has a name.
            if type(argSpec.name) ~= "string" or #argSpec.name < 3 do
                return false, "Invalid argument specification: " .. name .. " does not have a valid string name."
            end
            namedArgSpecs[name] = argSpec
        else
            return false, "Invalid argument specification: " .. name .. " doesn't have idx or name."
        end
    end

    local results = {}
    local idx = 1
    while idx <= #args do
        local parsed = false
        -- Try and see if there's an idx arg spec for this index first.
        for name, argSpec in pairs(idxArgSpecs) do
            if argSpec.idx == idx then
                local success, value = parseArgValue(argSpec, args[idx])
                if success then
                    results[name] = value
                    idxArgSpecs[name] = nil
                    parsed = true
                    break
                elseif not success and argSpec.required then
                    return false, "Failed to parse value for " .. name .. " argument: " .. value
                end
            end
        end

        -- If no idx arg spec could parse the argument, try a named one.
        if not parsed then
            if idx == #args then
                return false, "Missing value for argument " .. args[idx]
            end
            for name, argSpec in pairs(idxArgSpecs) do
                
            end
        end

        idx = idx + 1
    end

    return true, results
end

return buildscript
