--[[
Itemscript - A simplified set of methods for item manipulation.

Author: Andrew Lalis <andrewlalisofficial@gmail.com>


]]--

-- The itemscript module. Functions defined within this table are exported.
local itemscript = {}
itemscript.VERSION = "0.0.1"

-- Determines if an item stack matches the given name.
-- If fuzzy, then the item name will be matched against the given name.
local function stackMatches(itemStack, name, fuzzy)
    if itemStack == nil or itemStack.name == nil then return false end
    if fuzzy then return string.find(itemStack.name, name) ~= nil end
    return itemStack.name == name
end

local function splitString(str, sep)
    if sep == nil then sep = "%s" end
    local result = {}
    for s in string.gmatch(str, "([^"..sep.."]+)") do
        table.insert(result, s)
    end
    return result
end

-- Parses a filter expression string and returns a table representing the syntax tree.
-- An error is thrown if compilation fails.
--[[
    Item Filter Expressions:
    
    A filter expression is a way to define a complex method of matching item
    stacks.

    Grammar:

    word        = %a[%w%-_:]*       A whole or substring of an item's name.
    number      = %d+
    expr        = word              Matches item stacks whose name matches the given word.
                = #word             Matches item stacks whose name contains the given word.
                = (expr)
                = !expr             Matches item stacks that don't match the given expression.
                = expr | expr       Matches item stacks that match any of the given expressions (OR).
                = expr & expr       Matches item stacks that match all of the given expressions (AND).
                = expr > %d         Matches item stacks that match the given expression, and have more than N items.
                = expr >= %d        Matches item stacks that match the given expression, and have more than or equal to N items.
                = expr < %d         Matches item stacks that match the given expression, and have less than N items.
                = expr <= %d        Matches item stacks that match the given expression, and have less than or equal to N items.
                = expr = %d         Matches item stacks that match the given expression, and have exactly N items.
                = expr != %d        Matches item stacks that match the given expression, and do not have exactly N items.
    
    Examples:

    "#log > 10" matches any items containing the word "log", that have more than 10 items in the stack.
    "10% coal, 90% iron_ore" matches coal 10% of the time, and iron_ore 90% of the time.
]]--
function itemscript.parseFilterExpression(str)
    str = str:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace from the beginning and end of the string.
    
    -- Parse group constructs
    local ignoreRange = nil
    if string.sub(str, 1, 1) == "(" then
        local idx1, idx2 = string.find(str, "%b()")
        if idx1 == nil then
            error("Invalid group construct: \"" .. str .. "\".")
        end
        -- If the group is the whole expression, parse it. Otherwise, defer parsing to later.
        if idx2 == #str then
            return itemscript.parseFilterExpression(string.sub(str, idx1 + 1, idx2 - 1))
        else
            ignoreRange = {idx1, idx2}
        end
    end

    -- Parse logical group operators (OR and AND)
    local logicalGroupOperators = {
        { name = "OR", token = "|" },
        { name = "AND", token = "&" }
    }
    for _, operator in pairs(logicalGroupOperators) do
        local idx = string.find(str, operator.token)
        if idx ~= nil and (ignoreRange == nil or idx < ignoreRange[1] or idx > ignoreRange[2]) then
            return {
                type = operator.name,
                children = {
                    itemscript.parseFilterExpression(string.sub(str, 1, idx - 1)),
                    itemscript.parseFilterExpression(string.sub(str, idx + 1, -1))
                }
            }
        end
    end

    -- Parse item count arithmetic operators
    local arithmeticOperators = {
        ["LESS_THAN"] = "<",
        ["LESS_THAN_OR_EQUAL_TO"] = "<=",
        ["GREATER_THAN"] = ">",
        ["GREATER_THAN_OR_EQUAL_TO"] = ">=",
        ["EQUALS"] = "=",
        ["NOT_EQUALS"] = "!="
    }
    for typeName, token in pairs(arithmeticOperators) do
        local idx = string.find(str, token)
        if idx ~= nil and (ignoreRange == nil or idx < ignoreRange[1] or idx > ignoreRange[2]) then
            local subExpr = itemscript.parseFilterExpression(string.sub(str, 1, idx - 1))
            local numberExprIdx1, numberExprIdx2 = string.find(str, "%d+", idx + 1)
            if numberExprIdx1 == nil then
                error("Could not find number expression (%d+) in string: \"" .. string.sub(str, idx + 1, -1) .. "\".")
            end
            local numberValue = tonumber(string.sub(str, numberExprIdx1, numberExprIdx2))
            if numberValue == nil then
                error("Could not parse number from string: \"" .. string.sub(str, numberExprIdx1, numberExprIdx2) .. "\".")
            end
            return {
                type = typeName,
                expr = subExpr,
                value = numberValue
            }
        end
    end

    -- Parse NOT operator.
    if string.sub(str, 1, 1) == "!" then
        return {
            type = "NOT",
            expr = itemscript.parseFilterExpression(string.sub(str, 2, -1))
        }
    end

    -- Parse fuzzy and plain words.
    local fuzzy = false
    if string.sub(str, 1, 1) == "#" then
        fuzzy = true
        str = string.sub(str, 2, -1)
    end
    local wordIdx1, wordIdx2 = string.find(str, "%a[%w%-_]*")
    if wordIdx1 ~= nil then
        local value = string.sub(str, wordIdx1, wordIdx2)
        if not fuzzy and string.find(value, ":") == nil then
            value = "minecraft:" .. value
        end
        return {
            type = "WORD",
            value = value,
            fuzzy = fuzzy
        }
    end

    error("Invalid filter expression syntax: " .. str)
end

-- Compiles a filter function from a filter expression syntax tree.
function itemscript.compileFilter(expr)
    if expr.type == "WORD" then
        return function(item)
            return stackMatches(item, expr.value, expr.fuzzy)
        end
    end
    if expr.type == "NOT" then
        local subFilter = itemscript.compileFilter(expr.expr)
        return function (item)
            return not subFilter(item)
        end
    end
    if expr.type == "LESS_THAN" then
        local subFilter = itemscript.compileFilter(expr.expr)
        return function (item)
            return subFilter(item) and item.count < expr.value
        end
    end
    if expr.type == "GREATER_THAN" then
        local subFilter = itemscript.compileFilter(expr.expr)
        return function (item)
            return subFilter(item) and item.count > expr.value
        end
    end
    if expr.type == "LESS_THAN_OR_EQUAL_TO" then
        local subFilter = itemscript.compileFilter(expr.expr)
        return function (item)
            return subFilter(item) and item.count <= expr.value
        end
    end
    if expr.type == "GREATER_THAN_OR_EQUAL_TO" then
        local subFilter = itemscript.compileFilter(expr.expr)
        return function (item)
            return subFilter(item) and item.count >= expr.value
        end
    end
    if expr.type == "EQUALS" then
        local subFilter = itemscript.compileFilter(expr.expr)
        return function (item)
            return subFilter(item) and item.count == expr.value
        end
    end
    if expr.type == "NOT_EQUALS" then
        local subFilter = itemscript.compileFilter(expr.expr)
        return function (item)
            return subFilter(item) and item.count ~= expr.value
        end
    end
    if expr.type == "AND" then
        local subFilters = {}
        for _, childExpr in pairs(expr.children) do
            table.insert(subFilters, itemscript.compileFilter(childExpr))
        end
        return function (item)
            for _, subFilter in pairs(subFilters) do
                if not subFilter(item) then return false end
            end
            return true
        end
    end
    if expr.type == "OR" then
        local subFilters = {}
        for _, childExpr in pairs(expr.children) do
            table.insert(subFilters, itemscript.compileFilter(childExpr))
        end
        return function (item)
            for _, subFilter in pairs(subFilters) do
                if subFilter(item) then return true end
            end
            return false
        end
    end
    error("Invalid filter expression syntax tree item: " .. expr.type)
end

--[[
    Converts an arbitrary value to a filter function that can be applied to item
    stacks for filtering operations. The following types are supported:
    - strings are parsed and compiled to filter functions.
    - functions are assumed to be filter functions that take an item stack as
      a single parameter, and return true for a match, and false otherwise.
    - tables are assumed to be pre-parsed filter expression syntax trees.
]]--
function itemscript.filterize(value)
    if type(value) == "string" then
        return itemscript.compileFilter(itemscript.parseFilterExpression(value))
    elseif type(value) == "table" then
        return itemscript.compileFilter(value)
    elseif type(value) == "function" then
        return value
    else
        error("Invalid filterizable value. Expected filter expression string, syntax tree table, or filter function.")
    end
end

-- Finds the first matching slot for the given filter expression.
function itemscript.findSlot(filterExpr)
    local filter = itemscript.filterize(filterExpr)
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if filter(item) then return i end
    end
    return nil
end

-- Gets a list of all inventory slots that match the given filter expression.
function itemscript.findSlots(filterExpr)
    local filter = itemscript.filterize(filterExpr)
    local slots = {}
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if filter(item) then
            table.insert(slots, i)
        end
    end
end

-- Gets the total number of items in the turtle's inventory that match the given expression.
function itemscript.totalCount(filterExpr)
    local count = 0
    for _, slot in pairs(itemscript.findSlots(filterExpr)) do
        local item = turtle.getItemDetail(slot)
        count = count + item.count
    end
    return count
end

-- Select the first slot containing a matching item stack for a filter.
-- Returns a boolean indicating whether we could find and select the item.
function itemscript.select(filterExpr)
    local slot = itemscript.findSlot(filterExpr)
    if slot ~= nil then
        turtle.select(slot)
        return true
    end
    return false
end

-- Selects a random slot containing a matching item stack.
function itemscript.selectRandom(filterExpr)
    local eligibleSlots = itemscript.findSlots(filterExpr)
    if #eligibleSlots == 0 then return false end
    local slot = eligibleSlots[math.random(1, #eligibleSlots)]
    turtle.select(slot)
    return true
end

-- Selects a slot containing at least 1 of an item type matching
-- the given filter expression.
function itemscript.selectOrWait(filterExpr)
    local filter = itemscript.filterize(filterExpr)
    while not itemscript.select(filter) do
        print("Couldn't find at least 1 item matching the filter expression: \"" .. filterExpr .. "\". Please add it.")
        os.pullEvent("turtle_inventory")
    end
end

function itemscript.selectRandomOrWait(filterExpr)
    local filter = itemscript.filterize(filterExpr)
    while not itemscript.select(filter) do
        print("Couldn't find at least 1 item matching the filter expression: \"" .. filterExpr .. "\". Please add it.")
        os.pullEvent("turtle_inventory")
    end
end

-- Selects the first empty slot, if there is one. Returns true if an empty slot could be selected.
function itemscript.selectEmpty()
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item == nil then
            turtle.select(i)
            return true
        end
    end
    return false
end

-- Selects the first empty slot, or prompts the user to remove items so that an empty slot can be selected.
function itemscript.selectEmptyOrWait()
    while not itemscript.selectEmpty() do
        print("Couldn't find an empty slot. Please remove some items.")
        os.pullEvent("turtle_inventory")
    end
end

-- Helper function to drop items in a flexible way, using a drop function and filtering function.
local function dropFiltered(dropFunction, filterExpr)
    local filter = itemscript.filterize(filterExpr)
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if filter(item) then
            turtle.select(i)
            dropFunction()
        end
    end
end

function itemscript.dropAll(filterExpr)
    dropFiltered(turtle.drop, filterExpr)
end

function itemscript.dropAllDown(filterExpr)
    dropFiltered(turtle.dropDown, filterExpr)
end

function itemscript.dropAllUp(filterExpr)
    dropFiltered(turtle.dropUp, filterExpr)
end

return itemscript