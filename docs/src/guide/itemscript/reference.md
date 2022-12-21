# Module Reference

The following is a complete reference of the **itemscript** module. All symbols defined here belong to the `itemscript` module, and can be accessed via an instance of that module. For example:

```lua
local is = require("itemscript")
is.dropAll("stone")
```

## `totalCount(filterExpr)`

Computes the total number of items matching the given [filter expression](./filters.md).

## `select(filterExpr)`

Selects the first inventory slot containing an item that matches the given [filter expression](./filters.md). Returns `true` if a slot was selected successfully, or `false` if no matching item could be found.

## `dropAll(filterExpr)`

Drops all items from the turtle's inventory matching the given [filter expression](./filters.md).

## `dropAllDown(filterExpr)`

Variant of [dropAll](#dropall-filterexpr) which drops items downward.

## `dropAllUp(filterExpr)`

Variant of [dropAll](#dropall-filterexpr) which drops items upward.