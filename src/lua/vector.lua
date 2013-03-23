Vector = {}

Vector.mt = {}


function Vector.mt.__index(t,k)
  if k=="x" then return t[1]
  elseif k=="y" then return t[2] 
  else return Vector[k]
  end
end

function Vector.mt.__newindex(t,k,v)
  if k=="x" then t[1] = v
  elseif k=="y" then t[2] = v
  end
end

function Vector.mt.__add(a,b) 
  local r = Vector.new()
  r[1] = a[1] + b[1]
  r[2] = a[2] + b[2]
  return r
end


function Vector.mt.__sub(a,b) 
  local r = Vector.new()
  r[1] = a[1] - b[1]
  r[2] = a[2] - b[2]
  return r
end

function Vector.mt.__mul(vec,x)
  local r = Vector.new()
  if type(x)=="table" then
    r[1] = vec[1] * x[1]
    r[2] = vec[2] * x[2]
  else
    r[1] = vec[1] * x
    r[2] = vec[2] * x
  end
  return r
end


function Vector.new(x,y)
  local o = {
    x or 0,y or 0,
  }
  setmetatable(o, Vector.mt)
  return o
end

function Vector.len(v)
  return math.sqrt((v.x * v.x) + (v.y * v.y))
end

function Vector.normalise(v)
  local r = Vector.new()
  local l = Vector.len(v)
  r.x = v.x/l
  r.y = v.y/l
  return r
end



Vector.Down = Vector.new(0,-1)
Vector.Up = Vector.new(0,1)
Vector.Left = Vector.new(-1,0)
Vector.Right = Vector.new(1,0)


