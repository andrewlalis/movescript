--[[
Itemscript - A simplified set of methods for item manipulation.

Author: Andrew Lalis <andrewlalisofficial@gmail.com>


]]--
VERSION = "0.0.1"

local t = turtle

-- The itemscript module. Functions defined within this table are exported.
local itemscript = {}

-- Determines if an item stack matches the given name.
-- If fuzzy, then the item name will be matched against the given name.
local function stackMatches(itemStack, name, fuzzy)
    return itemStack ~= nil and
        (
            (not fuzzy and itemStack.name == name) or
            string.find(itemStack.name, name)
        )
end

--[[
The following describes an item filter:
A table containing a filter mechanism.
{
    filterFunction = stackMatches,
    fuzzy = false,
    whitelist = true
}
The filterFunction is defined like so:
function filterFunction(item, filter)
    return true | false
end
]]--

local function makeItemFilter(var, fuzzy, whitelist)
    local filter = {
        filterFunction = nil,
        fuzzy = fuzzy or false,
        whitelist = whitelist
    }
    if type(var) == "string" then
        -- If the filter is a single item name, define a single-item filter that matches against the name.
        filter.filterFunction = function (item, filter)
            local matches = stackMatches(item, var, filter.fuzzy)
            if filter.whitelist then
                return matches
            else
                return not matches
            end
        end
    elseif type(var) == "table" then
        -- If the filter is a list of item names, define a multi-item filter.
        filter.filterFunction = function (item, filter)
            for _, itemName in pairs(var) do
                if filter.whitelist and stackMatches(item, itemName, filter.fuzzy) then
                    return true
                elseif not filter.whitelist and not stackMatches(item, itemName, filter.fuzzy) then
                    return false
                end
            end
            -- If whitelist and we couldn't find a match, return false.
            -- If blacklist and we couldn't find a non-match, return true.
            return not filter.whitelist
        end
    elseif type(var) == "function" then
        -- Otherwise, just use the provided filter.
        filter.filterFunction = var
    end
    filter.apply = function(item)
        return filter.filterFunction(item, filter)
    end
    return filter
end

-- Gets the total number of items of a certain type in the turtle's inventory.
function itemscript.totalCount(filter)
    local count = 0
    for i = 1, 16 do
        local item = t.getItemDetail(i)
        if filter.apply(item) then
            count = count + item.count
        end
    end
    return count
end

-- Selects a slot containing at least one of the given item type.
-- Returns a boolean indicating whether we could find and select the item.
function itemscript.select(filter)
    for i = 1, 16 do
        local item = t.getItemDetail(i)
        if filter.apply(item) then
            t.select(i)
            return true
        end
    end
    return false
end

-- Helper function to drop items in a flexible way, using a drop function and filtering function.
local function dropFiltered(dropFunction, filter)
    for i = 1, 16 do
        local item = t.getItemDetail(i)
        if filter.apply(item) then
            t.select(i)
            dropFunction()
        end
    end
end

function itemscript.dropAll(filter)
    dropFiltered(t.drop, filter)
end

function itemscript.dropAllDown(filter)
    dropFiltered(t.dropDown, filter)
end

function itemscript.dropAllUp(filter)
    dropFiltered(t.dropUp, filter)
end

-- Cleans up the turtle's inventory by compacting all stacks of items.
function itemscript.organize()
    error("Not yet implemented.")
end

return itemscript