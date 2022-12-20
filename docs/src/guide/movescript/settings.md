# Settings

As you've seen in some examples, scripts can be run via `movescript.run("3F")`. But under the hood, every script is run using a table of settings that help to define what to do in certain situations to allow for predictable, safe behavior.

| Setting | Type | Description | Default Value |
| ------- | ---- | ----------- | ------------- |
| `debug` | boolean | If true, extra debug information will be printed as your script is run. | `false` |
| `safe` | boolean | Tells whether the turtle should move safely; safe movement means repeating a movement until we confirm that it succeeds. | `true` |
| `destructive` | boolean | Tells whether the turtle should destroy blocks in its movement path in order to complete its actions. | `false` |
| `fuels` | table of strings | A list of names of items that the turtle should consider to be fuel, in case it needs to refuel itself. | `{"minecraft:coal", "minecraft:charcoal"}` |

## User-Defined

If you'd like to change how your script is executed, you can pass your own settings table to `movescript.run`, like in the example below:

```lua
local ms = require("movescript")
local mySettings = {
    debug = true,
    safe = true,
    destructive = true,
    fuels = {"minecraft:charcoal", "minecraft:spruce_log"}
}
ms.run("10F", mySettings)
```

Please make sure that if you decide to customize settings, that you thoroughly read and understand what they mean. Failure to do so could lead to an inoperable turtle, or at worst, unintended destruction.

## Updating Defaults
While not recommended, you are also able to override the default settings for Movescript once, and have them take effect globally to all scripts run by the module. To do so, simply modify the `defaultSettings` table included in the movescript module.

```lua
-- Example: Enable debug for all scripts that will be executed.
local ms = require("movescript")
ms.defaultSettings.debug = true

ms.run("3F")
ms.run("3B")
```
