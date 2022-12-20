--[[
Itemscript - A simplified set of methods for item manipulation.

Author: Andrew Lalis <andrewlalisofficial@gmail.com>


]]--
VERSION = "0.0.1"

local t = turtle

-- The itemscript module. Functions defined within this table are exported.
local itemscript = {}

local function itemStackMatches(itemStack, name, fuzzy)
    return itemStack ~= nil and
        (
            (not fuzzy and itemStack.name == name) or
            string.find(itemStack.name, name)
        )
end

-- Gets the total number of items of a certain type in the turtle's inventory.
-- If fuzzy is set as true, then it'll match substrings matching the given name.
function itemscript.totalCount(name, fuzzy)
    fuzzy = fuzzy or false
    local count = 0
    for i = 1, 16 do
        local item = t.getItemDetail(i)
        if itemStackMatches(item, name, fuzzy) then
            count = count + item.count
        end
    end
    return count
end

-- Selects a slot containing at least one of the given item type.
-- Returns a boolean indicating whether we could find and select the item.
function itemscript.select(name, fuzzy)
    fuzzy = fuzzy or false
    for i = 1, 16 do
        local item = t.getItemDetail(i)
        if itemStackMatches(item, name, fuzzy) then
            t.select(i)
            return true
        end
    end
    return false
end

local function itemMatchesFilter(item, name, fuzzy)
    fuzzy = fuzzy or false
    return (not fuzzy and item.name == name) or string.find(item.name, name)
end

local function itemNotMatchesFilter(item, name, fuzzy)
    return not itemMatchesFilter(item, name, fuzzy)
end

local function dropFiltered(name, fuzzy, dropFunction, filterFunction)
    for i = 1, 16 do
        local item = t.getItemDetail(i)
        if filterFunction(item, name, fuzzy) then
            t.select(i)
            dropFunction()
        end
    end
end

function itemscript.dropAll(name, fuzzy)
    dropFiltered(name, fuzzy or false, t.drop, itemMatchesFilter)
end

function itemscript.dropAllDown(name, fuzzy)
    dropFiltered(name, fuzzy or false, t.dropDown, itemMatchesFilter)
end

function itemscript.dropAllUp(name, fuzzy)
    dropFiltered(name, fuzzy or false, t.dropUp, itemMatchesFilter)
end

function itemscript.dropAllExcept(name, fuzzy)
    dropFiltered(name, fuzzy or false, t.drop, itemNotMatchesFilter)
end

function itemscript.dropAllDownExcept(name, fuzzy)
    dropFiltered(name, fuzzy or false, t.dropDown, itemNotMatchesFilter)
end

-- Cleans up the turtle's inventory by compacting all stacks of items.
function itemscript.organize()
    error("Not yet implemented.")
end

return itemscript