
FpsCounter = Class:new
{
  elapsed = 0.0,
  newVal = false,
  counter = 0.0,
  cur = 0.0
}


function FpsCounter:update(deltaMs)
  self.counter = self.counter + 1.0
  self.elapsed = self.elapsed + deltaMs
  if self.elapsed > 1000 then
    self.elapsed = self.elapsed - 1000
    self.newVal = true
    self.cur = self.counter
    self.counter = 0
  end
end

function FpsCounter:hasNew()
  ret = self.newVal
  self.newVal = false
  return ret
end

function FpsCounter:current()
  return self.cur
end

