a="0.0.1"local d=turtle local e={}e.defaultSettings={debug=false,safe=true,destructive=false,fuels={"minecraft:coal","minecraft:charcoal"}}local function f(t,u)if u and u.debug then print("[MS] "..t)end end function d.digBack(t)d.turnRight()d.turnRight()d.dig(t)d.turnRight()d.turnRight()end function d.detectBack()d.turnRight()d.turnRight()local t=d.detect()d.turnRight()d.turnRight()return t end local function g(t,u,v,w)w=w or e.defaultSettings b=w.safe or e.defaultSettings.safe c=w.destructive or e.defaultSettings.destructive local x=t()if not b then return end while not x do f("Unable to move.",w)if c and v()then f("Detected a block in the way; attempting to remove it.",w)u()end x=t()end end local function h(t)f("Moving up.",t)g(d.up,d.digUp,d.detectUp,t)end local function j(t)f("Moving down.",t)g(d.down,d.digDown,d.detectDown,t)end local function k(t)f("Moving forward.",t)g(d.forward,d.dig,d.detect,t)end local function l(t)f("Moving back.",t)g(d.back,d.digBack,d.detectBack,t)end local function m(t)f("Turning right.",t)d.turnRight()end local function n(t)f("Turning left.",t)d.turnLeft()end local o={["U"]={f=h,needsFuel=true},["D"]={f=j,needsFuel=true},["L"]={f=n,needsFuel=false},["R"]={f=m,needsFuel=false},["F"]={f=k,needsFuel=true},["B"]={f=l,needsFuel=true},["P"]={f=d.place,needsFuel=false},["Pu"]={f=d.placeUp,needsFuel=false},["Pd"]={f=d.placeDown,needsFuel=false},["A"]={f=d.attack,needsFuel=false},["Au"]={f=d.attackUp,needsFuel=false},["Ad"]={f=d.attackDown,needsFuel=false}}local function p(t)f("Refueling...",t)local u=t.fuels or e.defaultSettings.fuels local v=false for w=1,16 do local x=d.getItemDetail(w)if x~=nil then for y,z in pairs(u)do if x.name==z then d.select(i)if d.refuel(x.count)then v=true end break end end end end return v end local function q(t,u)p(u)while d.getFuelLevel<t do print("[MS] Fuel level is too low. Level: "..d.getFuelLevel()..". Required: "..t..". Please add some of the following fuels:")local v=u.fuels or e.defaultSettings.fuels for x,y in pairs(v)do print("  - "..y)end local w=false while not w do os.pullEvent("turtle_inventory")w=p()end end end local function r(t,u)local v=o[t.action]if v then f("Executing action \""..t.action.."\" "..t.count.." times.",u)local w=((u.safe or true)and(v.needsFuel)and(t.count>d.getFuelLevel()))if w then local x=t.count q(x,u)end for x=1,t.count do v.f()end end end local function s(t,u)local v={}for w in string.gfind(t,"%W*(%d*%u%l*)%W*")do local x,y=string.find(w,"%d+")local z,A=string.find(w,"%u%l*")local B=1 if x~=nil then B=tonumber(string.sub(w,x,y))end local C=string.sub(w,z,A)if B<1 or B>d.getFuelLimit()then error("Instruction at index "..z.." has an invalid count of "..B..". It should be >= 1 and <= "..d.getFuelLimit())end if o[C]==nil then error("Instruction at index "..z..", \""..C.."\", does not refer to a valid action.")end table.insert(v,{action=C,count=B})f("Parsed instruction: "..w,u)end return v end function e.run(t,u)u=u or e.defaultSettings t=t or""f("Executing script: "..t,u)local v=s(t,u)for w,x in pairs(v)do r(x,u)end end function e.runFile(t,u)local v=fs.open(t,"r")local w=v.readAll()v.close()e.run(w,u)end return e