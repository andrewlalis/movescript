a="0.0.1"local b=turtle local c={}local function d(k,l,m)return k~=nil and((not m and k.name==l)or string.find(k.name,l))end local function e(k)return function(l)return not k(l)end end local function f(k)return function(l)for m,n in pairs(k)do if not n(l)then return false end end return true end end local function g(k)return function(l)for m,n in pairs(k)do if n(l)then return true end end return false end end local function h(k)local l,m=string.find(k,"^[!#]+")local n=false local o=false if l~=nil then for q=l,m do local r=string.sub(k,q,q)if r=="!"then o=true elseif r=="#"then n=true end end k=string.sub(k,m+1,string.len(k))end local p=string.find(k,":")if p==nil and not n then k="minecraft:"..k end return function(q)if q==nil then return false end local r=d(q,k,n)if o then r=not r end return r end end local function i(k)if type(k)=="table"and#k>0 and type(k[1])=="string"then local l={}for m,n in pairs(k)do table.insert(l,h(n))end return g(l)elseif type(k)=="string"then return h(k)elseif type(k)=="function"then return k else error("Unsupported filter type: "..type(k))end end function c.totalCount(k)local l=i(k)local m=0 for n=1,16 do local o=b.getItemDetail(n)if l(o)then m=m+o.count end end return m end function c.select(k)local l=i(k)for m=1,16 do local n=b.getItemDetail(m)if l(n)then b.select(m)return true end end return false end local function j(k,l)for m=1,16 do local n=b.getItemDetail(m)if l(n)then b.select(m)k()end end end function c.dropAll(k)j(b.drop,i(k))end function c.dropAllDown(k)j(b.dropDown,i(k))end function c.dropAllUp(k)j(b.dropUp,i(k))end function c.organize()error("Not yet implemented.")end return c