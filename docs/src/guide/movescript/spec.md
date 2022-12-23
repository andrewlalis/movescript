# Script Specification

Every movescript must follow the outline defined in this specification.

Each script consists of zero or more **instructions** or **repeated instructions**, separated by zero or more whitespace characters.

## Instructions

An instruction consists of an optional positive integer number, followed by a required uppercase character, and optionally followed by a series of lowercase characters.

```lua
-- The regex used to parse instructions.
instruction = string.find(script, "%s*(%d*%u%l*)%s*")
```

Each instruction can be split into two parts: the **action**, and the **count**. The action is the textual part of the instruction, and maps to a turtle behavior. The count is the optional numerical part of the instruction, and defaults to `1` if no number is provided.

Here are some examples of valid instructions: `3F`, `U`, `1R`

Some instructions may allow you to specify additional options. These can be defined as key-value pairs in parentheses after the action part.

For example: `4A(delay=0.25, file=tmp.txt)`

## Repeated Instructions

A repeated instruction is a grouping of instructions that are repeated a specified number of times. It's denoted as a positive integer number, followed by a series of [instructions](#instructions) within parentheses.

For example: `22(AF)` - We execute the instructions `A` and `F` 22 times.

## Actions

The following table lists all actions that are available in Movescript. Attempting to invoke an action not listed here will result in an error that will terminate your script.

| Action | Description                                      | Needs Fuel |
| ------ | ------------------------------------------------ | ---------- |
| `U`    | Move up.                                         | ✅         |
| `D`    | Move down.                                       | ✅         |
| `L`    | Turn left.                                       | ❌         |
| `R`    | Turn right.                                      | ❌         |
| `F`    | Move forward.                                    | ✅         |
| `B`    | Move backward.                                   | ✅         |
| `P`    | Place the selected item in front of the turtle.  | ❌         |
| `Pu`   | Place the selected item above the turtle.        | ❌         |
| `Pd`   | Place the selected item below the turtle.        | ❌         |
| `A`    | Attack in front of the turtle.                   | ❌         |
| `Au`   | Attack above the turtle.                         | ❌         |
| `Ad`   | Attack below the turtle.                         | ❌         |

For example, if we want our turtle to go forward 3 times, instead of writing `turtle.forward()` 3 times, we can just do the following:

```lua
local ms = require("movescript")
ms.run("3F")
```

### Fueled Actions

Some actions require fuel to execute successfully. Movescript will compute the fuel required to perform the upcoming behaviors in its script, and if needed, it will automatically refuel itself using any items matching the list of fuels defined in [settings](settings.md).

If the turtle isn't able to attain the required fuel from its own inventory, it will pause execution of the script and prompt the operator to insert fuel into the turtle's inventory before it will resume.

> Note: If the `safe` setting is set to `false`, no fuel checks will be done. The operator is responsible for ensuring the turtle will have enough fuel to complete its actions.

## Examples

The following snippets show a few example scripts, along with a description of what they'll do.

`3F2U1L` - Move forward 3 blocks, then up 2 blocks, and turn left.

`B2RAd` - Move back 2 blocks, then turn right twice, and then attack downward.


