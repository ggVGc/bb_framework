function list_iter (t)
  local i = 0
  local n = table.getn(t)
  return function ()
    i = i + 1
    if i <= n then return t[i] end
  end
end


function makeObj(s,o)
  local o = o or {}
  setmetatable(o,s)
  s.__index = s
  return o
end
