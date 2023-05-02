# Filters

Most of the functions provided by Itemscript make use of *filter expressions*. You'll often see it denoted in function parameters as `filterExpr`. A filter expression can be one of several things:

- A function that takes an `item` (as obtained from `getItemDetail`) and returns a boolean `true` if the item matches, or `false` if it doesn't.
- A string or list of strings (see [filter expression strings](#filter-expression-strings)).

## Filter Functions

Filter functions **must** follow these rules to avoid errors or undefined behavior:

- The function accepts a single `item` parameter, which may be `nil`, or a table like `{ name = "item_name", count = 32 }`.
- The function returns `true` if the given item should pass the filter or `false` if not.

Below is a simple example of a filter function that only allows item stacks with more than 10 items.

```lua
function myFilterFunction(item)
    return item ~= nil and item.count > 10
end
```

## Filter Expression Strings

In the case of strings, a **filter expression string** is a string that can be used to match against an item with some advanced options.

The most basic form of an expression string is just an item name, like `"minecraft:dirt"`, or `"create:train_door"`. Most normal items will begin with the `minecraft:` *namespace* prefix. If you don't include such a prefix, and you're not doing a [fuzzy match](#fuzzy-match), itemscript will add `minecraft:` for you.

### Grammar

Filter expressions can be summarized with a BNF-style grammar description.

```
word        = %a[%w%-_:]*       A whole or substring of an item's name.
number      = %d+
expr        = word              Matches item stacks whose name matches the given word.
            = #word             Matches item stacks whose name contains the given word.
            = (expr)            Grouping of a nested expression.
            = !expr             Matches item stacks that don't match the given expression.
            = expr | expr       Matches item stacks that match any of the given expressions (OR).
            = expr & expr       Matches item stacks that match all of the given expressions (AND).
            = expr > number     Matches item stacks that match the given expression, and have more than N items.
            = expr >= number    Matches item stacks that match the given expression, and have more than or equal to N items.
            = expr < number     Matches item stacks that match the given expression, and have less than N items.
            = expr <= number    Matches item stacks that match the given expression, and have less than or equal to N items.
            = expr = number     Matches item stacks that match the given expression, and have exactly N items.
            = expr != number    Matches item stacks that match the given expression, and do not have exactly N items.
```

For example, we can count the number of stone items in our inventory like this:

```lua
local is = require("itemscript")
print(is.totalCount("minecraft:stone"))
print(is.totalCount("stone")) -- "minecraft:" is added for us.
```

### Negation

If `!` is added to the beginning of the string, only items that **don't** match will pass the filter.

For example, suppose we want to drop everything except for oak planks:

```lua
local is = require("itemscript")
is.dropAll("!oak_planks")
```

### Fuzzy Match

If `#` is added to the beginning of the string, a *fuzzy* match will be performed, instead of a normal one. That is, instead of looking for an item whose name exactly matches, we look for the first item whose name we can find a given pattern in. In other words, normally when matching we check if `item.name == your_text`, and in a fuzzy match, we check if `string.find(item.name, your_text)` is not `nil`.

For example, suppose we want to count the total number of logs of any type. This would be quite tedious to do normally, but with fuzzy matching, it's trivial:

```lua
local is = require("itemscript")
print(is.totalCount("#log"))
```

Because a fuzzy match is nothing more than passing your text to Lua's `string.find` function, you can also take advantage of the more advanced *character classes* to define matching patterns. [Read about Lua's pattern matching documentation here.](https://www.lua.org/pil/20.2.html)

In the example below, we filter to all items that begin with the text `minecraft:red_` by using the special `^` character.

```lua
local is = require("itemscript")
print(is.totalCount("#^minecraft:red_"))
```