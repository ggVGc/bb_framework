Map = Class:new
{
  map_name="DEFAULT_MAP_NAME",
  height = 0,
  width = 0,
  start_height = 0,
  backdrop = nil,
  ground_level = 0
}

function Map:getHeight()
  return self.height
end

function Map:getWidth()
  return self.width
end

function Map:getSize()
  return self.width, self.height
end

function Map:getMapName()
  return self.map_name
end

function Map:getStartHeight()
  return self.start_height
end

function Map:getGroundLevel()
  return self.ground_level
end

function Map:getBackdrop()
  return self.backdrop
end

function Map:getRelativePosition(y)
  --return (y - self.ground_level) / (self.start_height - self.ground_level)
  return (self.start_height - self.ground_level) * (1-y) + self.ground_level
end
