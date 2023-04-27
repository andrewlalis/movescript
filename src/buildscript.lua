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
function buildscript.runWithItem(ms_script, filterExpr, settings)
    movescript.run(ms_script, settings, function() itemscript.selectOrWait(filterExpr) end)
end

-- Runs a movescript script, while selecting random items that match a filter.
function buildscript.runWithRandomItems(ms_script, filterExpr)
    movescript.run(ms_script, settings, function() itemscript.selectRandomOrWait(filterExpr) end)
end

-- Parses a value for an argument specification from a raw value.
local function parseArgValue(argSpec, arg)
    if argSpec.required and (not arg or #arg < 1) then
        return false, "Missing required value."
    end
    if argSpec.type == "string" then
        return true, arg
    elseif argSpec.type == "number" then
        local num = tonumber(arg)
        if not num and argSpec.required then
            return false, "Invalid number."
        end
        return true, num
    elseif argSpec.type == "bool" then
        local txt = string.lower(arg)
        if txt == "true" or txt == "t" or txt == "yes" or txt == "y" then
            return true, true
        else
            return true, false
        end
    else
        return false, "Unknown type: " .. argSpec.type
    end
end

-- Parses arguments according to a specification table, for common building
-- scripts, and returns a table with key-value pairs for each arg.
-- The specification table should be formatted like so:
-- {
--   argName = { type = "string", required = true, idx = 1 },
--   namedArg = { name = "-f", required = true, type = "bool" }
-- }
-- Supported types: string, number, bool
function buildscript.parseArgs(args, spec)
    for name, argSpec in pairs(spec) do
        if argSpec.idx ~= nil then
            if type(argSpec.idx) ~= "number" or argSpec.idx < 1 then
                return false, "Invalid argument specification: " .. name .. " does not have a valid numeric index."
            end
        elseif argSpec.name ~= nil then
            if type(argSpec.name) ~= "string" or #argSpec.name < 3 then
                return false, "Invalid argument specification: " .. name .. " does not have a valid string name."
            end
        else
            return false, "Invalid argument specification: " .. name .. " doesn't have idx or name."
        end
        if not argSpec.type then argSpec.type = "string" end
    end

    local results = {}

    -- Iterate over each argument specification, and try and find a value for it.
    for name, argSpec in pairs(spec) do
        if argSpec.idx then
            -- Parse a positional argument.
            if argSpec.idx > #args and argSpec.required then
                return false, "Missing required positional argument " .. name .. " at index " .. argSpec.idx
            end
            if argSpec.idx > #args then
                results[name] = nil
            else
                local success, value = parseArgValue(argSpec, args[argSpec.idx])
                if not success then
                    return false, "Failed to parse value for argument " .. name .. ": " .. value
                end
                results[name] = value
            end
        else
            -- Parse a named argument by iterating over all args until we find one matching the name.
            local valueFound = false
            for idx, arg in pairs(args) do
                if arg == argSpec.name then
                    if idx >= #args and argSpec.required then
                        return false, "Missing value for required argument " .. name
                    end
                    local success, value = parseArgValue(argSpec, args[idx + 1])
                    if not success then
                        return false, "Failed to parse value for argument " .. name .. ": " .. value
                    end
                    results[name] = value
                    valueFound = true
                    break
                end
            end
            if argSpec.required and not valueFound then
                return false, "Missing argument: " .. name
            end
        end
    end

    return true, results
end

return buildscript
