

dofile("class.lua")
Camera = Class:new
{
  x = 0,
  y = 0,
  cam = nil,
  width_boundary = 0,
  height_boundary = 0
}

function Camera:init(w, h)
  self.cam = framework.Camera.new(w, h)
end

function Camera:setPosition(x, y)
end

function Camera:moveRelative(x, y)
  self:setPosition(self.x+x, self.y+y)
end

function Camera:getPosition()
  return self.x, self.y
end
function Camera:getWidth()
  return self.cam.getWidth()
end

function Camera:getHeight()
  return self.cam.getHeight()
end

function Camera:setWidth(v)
  self.cam.setWidth(v)
end
function Camera:setHeight(v)
  self.cam.setHeight(v)
end

function Camera:update(updateMs)
end

function Camera:apply()
  self.cam.apply()
end

function Camera:setBoundaries(width, height)
  self.width_boundary = width
  self.height_boundary = height
end
