# Module Reference

The following is a complete reference of the **movescript** module. All symbols defined here belong to the `movescript` module, and can be accessed via an instance of that module. For example:

```lua
local ms = require("movescript")
ms.run("2F")
```

## `parse(script, settings)`

Parses the given `script` string and returns a table containing the parsed instructions to be executed. This is mostly useful for debugging your scripts.

## `executeInstruction(instruction, settings, preExecuteHook, postExecuteHook)`

Executes a single instruction table using the given settings, and if pre- and post-execution hooks are defined, they will be invoked. This is mostly useful for debugging your scripts.

## `run(script, settings, preExecuteHook, postExecuteHook)`

Runs the given `script` string as a movescript, and optionally a `settings` table can be provided. Otherwise, [default settings](settings.md) will be used.

For example:

```lua
local ms = require("movescript")
ms.run("3F2R3B2LUD", {debug=true})
```

If you provide a non-nil `preExecuteHook` or `postExecuteHook` function, that function will run before or after each instruction in the script, respectively. This could be used to update other systems as to the robot's status, or to make sure items are selected.

## `runFile(filename, settings, preExecuteHook, postExecuteHook)`

Reads content from the given filename and executes it as a script. Just like with `run`, an optional `settings` table can be provided.

## `validate(script, settings)`

Validates the given `script`, by parsing its instructions in a wrapped [`pcall`](https://www.lua.org/pil/8.4.html). It returns `true` if the script is valid, or `false` and an error message describing why the script is not valid.

For example:

```lua
local ms = require("movescript")
local status, message = ms.validate("not a valid script.")
```

## `mirror(script)`

Mirrors the given `script`. That is, this swaps any `R` (turn right) instructions with `L` (turn left), which effectively mirrors the robot's motion relative to its original facing direction.

Returns the mirrored script which can then be run.

## `defaultSettings`

A table containing the default [settings](./settings.md) for any script executed by the movescript module.