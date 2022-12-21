# Getting Started

The Movescript module provides a simple interface for executing *movescript sources* as turtle programs. A *movescript source* is a compact set of instructions that can be interpreted by the Movescript module to tell the turtle to behave according to them.

## Installing

To install this module, run the following command from your turtle's console:

```shell
wget https://raw.githubusercontent.com/andrewlalis/movescript/main/min/movescript.lua movescript.lua
```

And then use it in a script:

```lua
local ms = require("movescript")
ms.run("5F2R2U5F2D2L")
```