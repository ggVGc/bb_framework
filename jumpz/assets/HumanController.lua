-- HumanController

dofile("character.lua")

HumanController = Class:new
{
  target = Character:new(),
  map = nil
}

function HumanController:init(map, resultList, characterId, texSheet, textureName)
  self.map = map

  self.target:init(resultList, characterId, texSheet, textureName)
  self.target:setPosition(0, self.map:getStartHeight())
  self.target:setGroundLevel(self.map:getGroundLevel())
end

function HumanController:update(deltaMs)
  self.target:update(deltaMs)
end

function HumanController:draw()
  self.target:draw()
end

function HumanController:getTarget()
  return self.target
end
