
Main = {}

local v = Vector.new(100,200)
local function f()
  if not done then 
    assert(v[1] == v.x)
    assert(v[2] == v.y)

    done = 1
  end
end

function Main.new(o)
  return {doFrame=f}
end

