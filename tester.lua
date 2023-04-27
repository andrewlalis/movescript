-- http://lua-users.org/wiki/TableSerialization
function print_r (t, name, indent)
    local tableList = {}
    function table_r (t, name, indent, full)
      local serial=string.len(full) == 0 and name
          or type(name)~="number" and '["'..tostring(name)..'"]' or '['..name..']'
      io.write(indent,serial,' = ') 
      if type(t) == "table" then
        if tableList[t] ~= nil then io.write('{}; -- ',tableList[t],' (self reference)\n')
        else
          tableList[t]=full..serial
          if next(t) then -- Table not empty
            io.write('{\n')
            for key,value in pairs(t) do table_r(value,key,indent..'\t',full..serial) end 
            io.write(indent,'};\n')
          else io.write('{};\n') end
        end
      else io.write(type(t)~="number" and type(t)~="boolean" and '"'..tostring(t)..'"'
                    or tostring(t),';\n') end
    end
    table_r(t,name or '__unnamed__',indent or '','')
  end

-- local ms = require("src/movescript")
-- print_r(ms.parse("35(2F(safe=false)R 3(L(delay=0.25, file=file.txt)UB))", {debug=true}))

-- local bs = require("src/buildscript")
-- local args = {...}
-- local spec = {
--   num = { type = "number", required = true, idx = 1 },
--   name = { name = "name", type = "bool", required = true }
-- }
-- local success, result = bs.parseArgs(args, spec)
-- print(success)
-- print_r(result)

local is = require("src/itemscript")
local t = is.parseFilterExpression("!log")
print_r(t, "filter_expression_syntax_tree", "  ")
local filter = is.compileFilter(t)
local item = {
  name = "minecraft:oak_log",
  count = 54
}
local matches = filter(item)
print(matches)
