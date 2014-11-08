framework.FpsCounter = {}
framework.FpsCounter.new = function()

local self = {
  elapsed = 0.0,
  newVal = false,
  counter = 0.0,
  cur = 0.0
}
self.update = function(deltaMs)
  self.counter = self.counter + 1.0
  self.elapsed = self.elapsed + deltaMs
  if self.elapsed >= 1000 then
    --self.elapsed = self.elapsed - 1000
    self.elapsed = 0
    self.newVal = true
    self.cur = self.counter
    self.counter = 0
  end
end

self.hasNew = function()
  local ret = self.newVal
  self.newVal = false
  return ret
end

self.current = function()
  return self.cur
end


return self
end



function framework.FpsCounter:update(deltaMs)
end

