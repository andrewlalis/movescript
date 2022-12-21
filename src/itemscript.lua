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

local function notFilter(filter)
    return function(item)
        return not filter(item)
    end
end

local function andFilter(filters)
    return function(item)
        for _, filter in pairs(filters) do
            if not filter(item) then
                return false
            end
        end
        return true
    end
end

local function orFilter(filters)
    return function(item)
        for _, filter in pairs(filters) do
            if filter(item) then
                return true
            end
        end
        return false
    end
end

-- Parses a filter expression string and returns a filter that implements it.
--[[
    Item Filter Expressions:
    
    A filter expression is a way to define a complex method of matching item
    stacks.

    Prepending ! will match any item stack whose name does not match.
    Prepending # will do a fuzzy match using string.find.
]]--
local function parseItemFilterExpression(expr)
    local prefixIdx, prefixIdxEnd = string.find(expr, "^[!#]+")
    local fuzzy = false
    local negated = false
    if prefixIdx ~= nil then
        for i = prefixIdx, prefixIdxEnd do
            if expr[i] == "!" then
                negated = true
            elseif expr[i] == "#" then
                fuzzy = true
            end
        end
        expr = string.sub(expr, prefixIdxEnd + 1, string.len(expr))
    end
    local namespaceSeparatorIdx = string.find(expr, ":")
    if namespaceSeparatorIdx == nil and not fuzzy then
        expr = "minecraft:" .. expr
    end
    return function(item)
        local matches = stackMatches(item, expr, fuzzy)
        if negated then
            matches = not matches
        end
        return matches
    end
end

-- Converts an arbitrary variable into a filter; useful for any function that's public, so users can supply any filter.
-- It converts the following:
-- filter function tables directly.
-- strings and lists of strings are translated into an item names filter.
-- Functions are added with default fuzzy and whitelist parameters.
local function convertToFilter(var)
    if type(var) == "table" and #var > 0 and type(var[1]) == "string" then
        local filters = {}
        for _, expr in pairs(var) do
            table.insert(filters, parseItemFilterExpression(expr))
        end
        return orFilter(filters)
    elseif type(var) == "string" then
        return parseItemFilterExpression(var)
    elseif type(var) == "function" then
        return var
    else
        error("Unsupported filter type: " .. type(var))
    end
end

-- Gets the total number of items in the turtle's inventory that match the given expression.
function itemscript.totalCount(filterExpr)
    local filter = convertToFilter(filterExpr)
    local count = 0
    for i = 1, 16 do
        local item = t.getItemDetail(i)
        if filter(item) then
            count = count + item.count
        end
    end
    return count
end

-- Selects a slot containing at least one of the given item type.
-- Returns a boolean indicating whether we could find and select the item.
function itemscript.select(filterExpr)
    local filter = convertToFilter(filterExpr)
    for i = 1, 16 do
        local item = t.getItemDetail(i)
        if filter(item) then
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
        if filter(item) then
            t.select(i)
            dropFunction()
        end
    end
end

function itemscript.dropAll(filterExpr)
    dropFiltered(t.drop, convertToFilter(filterExpr))
end

function itemscript.dropAllDown(filterExpr)
    dropFiltered(t.dropDown, convertToFilter(filterExpr))
end

function itemscript.dropAllUp(filterExpr)
    dropFiltered(t.dropUp, convertToFilter(filterExpr))
end

-- Cleans up the turtle's inventory by compacting all stacks of items.
function itemscript.organize()
    error("Not yet implemented.")
end

return itemscript