--[[
Movescript - A simplified robot script for ComputerCraft.

Author: Andrew Lalis <andrewlalisofficial@gmail.com>

Movescript provides a simpler, conciser way to program "turtles" (robots), so
that you don't need to get tired of typing "turtle.forward()" over and over.

]]--
VERSION = "0.0.1"

local t = turtle

-- The movescript module. Functions defined within this table are exported.
local movescript = {}

movescript.defaultSettings = {
    debug = false,
    safe = true,
    destructive = false,
    fuels = {"minecraft:coal", "minecraft:charcoal"}
}

local function debug(msg, settings)
    if settings and settings.debug then
        print("[MS] " .. msg)
    end
end

-- Helper function for turtle to dig backwards.
function t.digBack(side)
    t.turnRight()
    t.turnRight()
    t.dig(side)
    t.turnRight()
    t.turnRight()
end

-- Helper function for turtle to detect backwards.
function t.detectBack()
    t.turnRight()
    t.turnRight()
    local result = t.detect()
    t.turnRight()
    t.turnRight()
    return result
end

local function goDirection(dirFunction, digFunction, detectFunction, settings)
    settings = settings or movescript.defaultSettings
    safe = settings.safe or movescript.defaultSettings.safe
    destructive = settings.destructive or movescript.defaultSettings.destructive
    local success = dirFunction()
    if not safe then return end
    while not success do
        debug("Unable to move.", settings)
        if destructive and detectFunction() then
            debug("Detected a block in the way; attempting to remove it.", settings)
            digFunction()
        end
        success = dirFunction()
    end
end

local function goUp(settings)
    debug("Moving up.", settings)
    goDirection(t.up, t.digUp, t.detectUp, settings)
end

local function goDown(settings)
    debug("Moving down.", settings)
    goDirection(t.down, t.digDown, t.detectDown, settings)
end

local function goForward(settings)
    debug("Moving forward.", settings)
    goDirection(t.forward, t.dig, t.detect, settings)
end

local function goBack(settings)
    debug("Moving back.", settings)
    goDirection(t.back, t.digBack, t.detectBack, settings)
end

local function goRight(settings)
    debug("Turning right.", settings)
    t.turnRight()
end

local function goLeft(settings)
    debug("Turning left.", settings)
    t.turnLeft()
end

local actionMap = {
    ["U"] = {f = goUp, needsFuel = true},
    ["D"] = {f = goDown, needsFuel = true},
    ["L"] = {f = goLeft, needsFuel = false},
    ["R"] = {f = goRight, needsFuel = false},
    ["F"] = {f = goForward, needsFuel = true},
    ["B"] = {f = goBack, needsFuel = true},
    ["P"] = {f = t.place, needsFuel = false},
    ["Pu"] = {f = t.placeUp, needsFuel = false},
    ["Pd"] = {f = t.placeDown, needsFuel = false},
    ["A"] = {f = t.attack, needsFuel = false},
    ["Au"] = {f = t.attackUp, needsFuel = false},
    ["Ad"] = {f = t.attackDown, needsFuel = false}
}

-- Tries to refuel the turtle from all slots that contain a valid fuel.
-- Returns a boolean indicating if at least one piece of fuel was consumed.
local function refuelAll(settings)
    debug("Refueling...", settings)
    local fuels = settings.fuels or movescript.defaultSettings.fuels
    local refueled = false
    for slot = 1, 16 do
        local item = t.getItemDetail(slot)
        if item ~= nil then
            for _, fuelName in pairs(fuels) do
                if item.name == fuelName then
                    t.select(slot)
                    if t.refuel(item.count) then refueled = true end
                    break
                end
            end
        end
    end
    return refueled
end

-- Blocks until the turtle's fuel level is at least at the required level.
local function refuelToAtLeast(requiredLevel, settings)
    refuelAll(settings)
    while t.getFuelLevel() < requiredLevel do
        print(
            "[MS] Fuel level is too low. Level: " .. t.getFuelLevel() .. ". Required: " .. requiredLevel ..
            ". Please add some of the following fuels:"
        )
        local fuels = settings.fuels or movescript.defaultSettings.fuels
        for _, fuelName in pairs(fuels) do
            print("  - " .. fuelName)
        end
        local fuelUpdated = false
        while not fuelUpdated do
            os.pullEvent("turtle_inventory")
            fuelUpdated = refuelAll(settings)
        end
    end
end

-- Executes a single instruction. An instruction is a table with an "action"
-- and some attributes, such as if it needs fuel or not.
local function executeInstruction(instruction, settings)
    local action = actionMap[instruction.action]
    if action then
        debug("Executing action \"" .. instruction.action .. "\" " .. instruction.count .. " times.", settings)
        local shouldRefuel = (
            (settings.safe or true) and
            (action.needsFuel) and
            (instruction.count > t.getFuelLevel())
        )
        if shouldRefuel then
            local fuelRequired = instruction.count
            refuelToAtLeast(fuelRequired, settings)
        end
        for i = 1, instruction.count do action.f() end
    end
end

-- Parses a movescript script into a series of instruction tables.
local function parseScript(script, settings)
    local instructions = {}
    for instruction in string.gfind(script, "%W*(%d*%u%l*)%W*") do
        local countIdx, countIdxEnd = string.find(instruction, "%d+")
        local actionIdx, actionIdxEnd = string.find(instruction, "%u%l*")
        local count = 1
        if countIdx ~= nil then
            count = tonumber(string.sub(instruction, countIdx, countIdxEnd))
        end
        local action = string.sub(instruction, actionIdx, actionIdxEnd)
        if count < 1 or count > t.getFuelLimit() then
            error("Instruction at index " .. actionIdx .. " has an invalid count of " .. count .. ". It should be >= 1 and <= " .. t.getFuelLimit())
        end
        if actionMap[action] == nil then
            error("Instruction at index " .. actionIdx .. ", \"" .. action .. "\", does not refer to a valid action.")
        end
        table.insert(instructions, {action = action, count = count})
        debug("Parsed instruction: " .. instruction, settings)
    end
    return instructions
end

function movescript.run(script, settings)
    settings = settings or movescript.defaultSettings
    script = script or ""
    debug("Executing script: " .. script, settings)
    local instructions = parseScript(script, settings)
    for idx, instruction in pairs(instructions) do
        executeInstruction(instruction, settings)
    end
end

function movescript.runFile(filename, settings)
    local f = fs.open(filename, "r")
    local script = f.readAll()
    f.close()
    movescript.run(script, settings)
end

function movescript.validate(script, settings)
    return pcall(function () parseScript(script, settings) end)
end

return movescript
