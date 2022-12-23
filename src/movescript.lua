--[[
Movescript - A simplified robot script for ComputerCraft.

Author: Andrew Lalis <andrewlalisofficial@gmail.com>

Movescript provides a simpler, conciser way to program "turtles" (robots), so
that you don't need to get tired of typing "turtle.forward()" over and over.

]]--
VERSION = "0.0.1"

local t = turtle
-- For testing purposes, if the turtle API is not present, we inject our own.
if not t then t = {
    getFuelLimit = function() return 1000000000 end
} end

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

local function goUp(options, settings)
    debug("Moving up.", settings)
    goDirection(t.up, t.digUp, t.detectUp, settings)
end

local function goDown(options, settings)
    debug("Moving down.", settings)
    goDirection(t.down, t.digDown, t.detectDown, settings)
end

local function goForward(options, settings)
    debug("Moving forward.", settings)
    goDirection(t.forward, t.dig, t.detect, settings)
end

local function goBack(options, settings)
    debug("Moving back.", settings)
    goDirection(t.back, t.digBack, t.detectBack, settings)
end

local function goRight(options, settings)
    debug("Turning right.", settings)
    t.turnRight()
end

local function goLeft(options, settings)
    debug("Turning left.", settings)
    t.turnLeft()
end

local function place(options, settings)
    debug("Placing.", settings)
    t.place(options.text)
end

local function placeUp(options, settings)
    debug("Placing up.", settings)
    t.placeUp(options.text)
end

local function placeDown(options, settings)
    debug("Placing down.", settings)
    t.placeDown(options.text)
end

local function attack(options, settings)
    debug("Attacking.", settings)
    t.attack(options.side)
end

local function attackUp(options, settings)
    debug("Attacking up.", settings)
    t.attackUp(options.side)
end

local function attackDown(options, settings)
    debug("Attacking down.", settings)
    t.attackDown(options.side)
end

local function dig(options, settings)
    debug("Digging.", settings)
    t.dig(options.side)
end

local function digUp(options, settings)
    debug("Digging up.", settings)
    t.digUp(options.side)
end

local function digDown(options, settings)
    debug("Digging down.", settings)
    t.digDown(options.side)
end

local function suck(options, settings)
    debug("Sucking.", settings)
    local count = nil
    if options.count ~= nil then
        count = tonumber(options.count)
    end
    t.suck(count)
end

local function suckUp(options, settings)
    debug("Sucking up.", settings)
    local count = nil
    if options.count ~= nil then
        count = tonumber(options.count)
    end
    t.suckUp(count)
end

local function suckDown(options, settings)
    debug("Sucking down.", settings)
    local count = nil
    if options.count ~= nil then
        count = tonumber(options.count)
    end
    t.suckDown(count)
end

local function selectSlot(options, settings)
    local slot = 1
    if options.slot ~= nil then
        slot = tonumber(options.slot)
    end
    debug("Selecting slot " .. slot .. ".", settings)
    t.select(slot)
end

local function drop(options, settings)
    debug("Dropping.", settings)
    local count = nil
    if options.count ~= nil then
        count = tonumber(options.count)
    end
    t.drop(count)
end

local function dropUp(options, settings)
    debug("Dropping up.", settings)
    local count = nil
    if options.count ~= nil then
        count = tonumber(options.count)
    end
    t.dropUp(count)
end

local function dropDown(options, settings)
    debug("Dropping down.", settings)
    local count = nil
    if options.count ~= nil then
        count = tonumber(options.count)
    end
    t.dropDown(count)
end

local actionMap = {
    ["U"] = {f = goUp, needsFuel = true},
    ["D"] = {f = goDown, needsFuel = true},
    ["L"] = {f = goLeft, needsFuel = false},
    ["R"] = {f = goRight, needsFuel = false},
    ["F"] = {f = goForward, needsFuel = true},
    ["B"] = {f = goBack, needsFuel = true},
    ["P"] = {f = place, needsFuel = false},
    ["Pu"] = {f = placeUp, needsFuel = false},
    ["Pd"] = {f = placeDown, needsFuel = false},
    ["A"] = {f = attack, needsFuel = false},
    ["Au"] = {f = attackUp, needsFuel = false},
    ["Ad"] = {f = attackDown, needsFuel = false},
    ["Dg"] = {f = dig, needsFuel = false},
    ["Dgu"] = {f = digUp, needsFuel = false},
    ["Dgd"] = {f = digDown, needsFuel = false},
    ["S"] = {f = suck, needsFuel = false},
    ["Su"] = {f = suckUp, needsFuel = false},
    ["Sd"] = {f = suckDown, needsFuel = false},
    ["Eqr"] = {f = t.equipRight, needsFuel = false},
    ["Eql"] = {f = t.equipLeft, needsFuel = false},
    ["Sel"] = {f = selectSlot, needsFuel = false},
    ["Dr"] = {f = drop, needsFuel = false},
    ["Dru"] = {f = dropUp, needsFuel = false},
    ["Drd"] = {f = dropDown, needsFuel = false}
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
    if instruction.type == INSTRUCTION_TYPES.repeated then
        debug("Executing repeated instruction " .. instruction.count .. " times.", settings)
        for i = 1, instruction.count do
            for _, nestedInstruction in pairs(instruction.instructions) do
                executeInstruction(nestedInstruction, settings)
            end
        end
    elseif instruction.type == INSTRUCTION_TYPES.instruction then
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
            for i = 1, instruction.count do
                action.f(instruction.options, settings)
            end
        end
    end
end

local INSTRUCTION_TYPES = {
    repeated = 1,
    instruction = 2
}

local function parseInstructionOptions(text, settings)
    local idx, endIdx = string.find(text, "%b()")
    if idx == nil or endIdx - idx < 4 then return nil end
    local optionPairsText = string.sub(text, idx, endIdx)
    debug("Parsing instruction options: " .. optionPairsText, settings)
    local options = {}
    local nextIdx = 1
    while nextIdx < string.len(optionPairsText) do
        idx, endIdx = string.find(optionPairsText, "%w+=[%w_-%.]+", nextIdx)
        if idx == nil then break end
        local pairText = string.sub(optionPairsText, idx, endIdx)
        local keyIdx, keyEndIdx = string.find(pairText, "%w+")
        local key = string.sub(pairText, keyIdx, keyEndIdx)
        local valueIdx, valueEndIdx = string.find(pairText, "[%w_-%.]+", keyEndIdx + 2)
        local value = string.sub(pairText, valueIdx, valueEndIdx)
        options[key] = value
        debug("  Found option: key = " .. key .. ", value = " .. value, settings)
        nextIdx = endIdx + 2
    end
    return options
end

local function parseRepeatedInstruction(match, settings)
    debug("Parsing repeated instruction: " .. match, settings)
    local instruction = {}
    instruction.type = INSTRUCTION_TYPES.repeated
    local countIdx, countEndIdx = string.find(match, "%d+")
    instruction.count = tonumber(string.sub(match, countIdx, countEndIdx))
    if instruction.count < 0 then
        error("Repeated instruction cannot have a negative count.")
    end
    local innerScriptIdx, innerScriptEndIdx = string.find(match, "%b()", countEndIdx + 1)
    local innerScript = string.sub(match, innerScriptIdx + 1, innerScriptEndIdx - 1)
    instruction.instructions = movescript.parse(innerScript, settings)
    return instruction
end

local function parseInstruction(match, settings)
    debug("Parsing instruction: " .. match, settings)
    local instruction = {}
    instruction.type = INSTRUCTION_TYPES.instruction
    local countIdx, countEndIdx = string.find(match, "%d+")
    instruction.count = 1
    if countIdx ~= nil then
        instruction.count = tonumber(string.sub(match, countIdx, countEndIdx))
    end
    if instruction.count < 1 or instruction.count > t.getFuelLimit() then
        error("Instruction at index " .. actionIdx .. " has an invalid count of " .. instruction.count .. ". It should be >= 1 and <= " .. t.getFuelLimit())
    end
    local actionIdx, actionEndIdx = string.find(match, "%u%l*")
    instruction.action = string.sub(match, actionIdx, actionEndIdx)
    if actionMap[instruction.action] == nil then
        error("Instruction at index " .. actionIdx .. ", \"" .. instruction.action .. "\", does not refer to a valid action.")
    end
    return instruction
end

-- Parses a movescript script into a series of instruction tables.
--[[
    Movescript Grammar:
block:                instruction | repeatedInstructions

repeatedInstructions: count '(' {instruction | repeatedInstructions} ')'
  regex: %d+%s*%b()
instruction:          [count] action [actionOptions] <- Not yet implemented.
  regex: %d*%u%l*
count:                %d+

action:               %u%l*

actionOptions:        '(' {optionPair ','} ')'
  regex: %b()

optionPair:           optionKey '=' optionValue

optionKey:            %w+

optionValue:          [%w_-]+

]]--
function movescript.parse(script, settings)
    local instructions = {}
    local scriptIdx = 1
    while scriptIdx <= string.len(script) do
        local instruction = {}
        local repeatedMatchStartIdx, repeatedMatchEndIdx = string.find(script, "%d+%s*%b()", scriptIdx)
        local instructionMatchStartIdx, instructionMatchEndIdx = string.find(script, "%d*%u%l*", scriptIdx)
        -- Parse the first occurring matched pattern.
        if repeatedMatchStartIdx ~= nil and (instructionMatchStartIdx == nil or repeatedMatchStartIdx < instructionMatchStartIdx) then
            -- Parse repeated instructions.
            local match = string.sub(script, repeatedMatchStartIdx, repeatedMatchEndIdx)
            table.insert(instructions, parseRepeatedInstruction(match, settings))
            scriptIdx = repeatedMatchEndIdx + 1
        elseif instructionMatchStartIdx ~= nil and (repeatedMatchStartIdx == nil or instructionMatchStartIdx < repeatedMatchStartIdx) then
            -- Parse single instruction.
            local match = string.sub(script, instructionMatchStartIdx, instructionMatchEndIdx)
            local instruction = parseInstruction(match, settings)
            local optionsIdx, optionsEndIdx = string.find(script, "%s*%b()", instructionMatchEndIdx + 1)
            if optionsIdx ~= nil then
                -- Check that there's nothing but empty space between the instruction and the options text.
                if not string.find(string.sub(script, instructionMatchEndIdx + 1, optionsIdx - 1), "%S+") then
                    local optionsText = string.sub(script, optionsIdx, optionsEndIdx)
                    instruction.options = parseInstructionOptions(optionsText, settings)
                end
            end
            if instruction.options == nil then instruction.options = {} end
            table.insert(instructions, instruction)
            scriptIdx = instructionMatchEndIdx + 1
        else
            error("Invalid script characters found at index " .. scriptIdx)
        end
    end
    return instructions
end

function movescript.run(script, settings)
    settings = settings or movescript.defaultSettings
    script = script or ""
    debug("Executing script: " .. script, settings)
    local instructions = movescript.parse(script, settings)
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
    return pcall(function () movescript.parse(script, settings) end)
end

return movescript
