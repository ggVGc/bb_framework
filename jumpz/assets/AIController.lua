

dofile("class.lua")

AIController = Class:new
{
  target = nil,
  map = nil,
  fallY = 0,
  level = 1,
  startDelay = 0,
  relativePosition = 0
}

function AIController:modifyLevel(level)
  self.level = level
end

function AIController:getLevel()
  return self.level
end

function AIController:changeLevel(value)
  self.level = self.level + value
end

math.randomseed(os.time())
function AIController:init(map, resultList, characterId, texSheet, textureName)
  self.target = Character:new()
  self.map = map

  self.target:init(resultList, characterId, texSheet, textureName)
  self.target:setPosition(0, self.map:getStartHeight())
  self.target:setGroundLevel(self.map:getGroundLevel())

  self:setFallY()

end

function AIController:update(deltaMs)
  --framework.trace(self.target:percentageToGround())

  --framework.trace(self.target.velocity)
  --framework.trace(self.target.velocityDeathThreshold)
  --framework.trace(self.target.slowFallVelocity)
  --framework.trace(dmg)

  self.target:doInput(false)
  if self.target.gameStarted then
    if self.target:getStateName() == "idle" then
      self.startDelay = self.startDelay - deltaMs
      if self.startDelay < 0 then
        self.target:doInput(true)
      end
    end

    local targetX, targetY = self.target:getPosition()
    if self.target:getStateName() == "fall" then
      if targetY < self.fallY then
        self.target:doInput(true)
      end
    end

    if self.target:getStateName() == "ground" then
      self.target:doInput(true)
    end
  end

  self.target:update(deltaMs)
end

function AIController:draw()
  self.target:draw()
end

function AIController:getTarget()
  return self.target
end

math.randomseed(os.time()) 
function AIController:setFallY()
  math.random()
  math.random()
  math.random()

  if self:getLevel() == 1 then
    self.relativePosition = math.random(self.map:getRelativePosition(0.6), self.map:getRelativePosition(0.6))
    self.startDelay = math.random(500, 1000)
  elseif self:getLevel() == 2 then
    self.relativePosition = math.random(self.map:getRelativePosition(0.6), self.map:getRelativePosition(0.4))
  end
 

  self.fallY = self.relativePosition
end

function AIController:reset()
  self:setFallY()
  self.target:reset(self.map:getStartHeight())
end
