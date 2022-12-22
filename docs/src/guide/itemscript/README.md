# Getting Started

The Itemscript module provides a flexible, powerful interface for managing a turtle's inventory, and any connected inventories.

## Installing

To install this module, run the following command from your turtle's console:

```shell
wget https://andrewlalis.github.io/movescript/scripts/itemscript.lua
```

And then use it in a script:

```lua
local is = require("itemscript")
print("Non-log items: " .. is.totalCount("!log"))
```
