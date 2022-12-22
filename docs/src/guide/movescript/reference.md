# Module Reference

The following is a complete reference of the **movescript** module. All symbols defined here belong to the `movescript` module, and can be accessed via an instance of that module. For example:

```lua
local ms = require("movescript")
ms.run("2F")
```

## `run(script, settings)`

Runs the given `script` string as a movescript, and optionally a `settings` table can be provided. Otherwise, [default settings](settings.md) will be used.

For example:

```lua
local ms = require("movescript")
ms.run("3F2R3B2LUD", {debug=true})
```

## `runFile(filename, settings)`

Reads content from the given filename and executes it as a script. Just like with `run`, an optional `settings` table can be provided.

## `validate(script, settings)`

Validates the given `script`, by parsing its instructions in a wrapped [`pcall`](https://www.lua.org/pil/8.4.html). It returns `true` if the script is valid, or `false` and an error message describing why the script is not valid.

For example:

```lua
local ms = require("movescript")
local status, message = ms.validate("not a valid script.")
```

## `defaultSettings`

A table containing the default [settings](./settings.md) for any script executed by the movescript module.