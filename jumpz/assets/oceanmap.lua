dofile("map.lua")

OceanMap = Map:new()

function OceanMap:init()
  self.height = 2280
  self.start_height = 2100
  self.ground_level = 60
end

function OceanMap:update(deltaMs)
end

function OceanMap:draw()
end
