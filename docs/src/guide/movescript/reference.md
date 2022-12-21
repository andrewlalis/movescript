# Module Reference

The following is a complete reference of the **movescript** module. All symbols defined here belong to the `movescript` module, and can be accessed via an instance of that module. For example:

```lua
local ms = require("movescript")
ms.run("2F")
```

## Functions

### `run(script, settings)`

Runs the given `script` string as a movescript, and optionally a `settings` table can be provided. Otherwise, [default settings](settings.md) will be used.

### `runFile(filename, settings)`

Reads content from the given filename and executes it as a script. Just like with `run`, an optional `settings` table can be provided.

## Variables

### `defaultSettings`

A table containing the default settings for any script executed by the movescript module.