dofile("characterstate.lua")
dofile("idlestate.lua")

Character = Class:new
{
  x=0,
  y=0,
  characterSprite = nil, 
  gameStarted = false,
  characterState = nil,
  groundLevel = 0,
  falling = false,
  velocity = 0,
  velocityDeathThreshold = 0,
  maxVelocity = 0,
  breakForce = 0,
  breakForceStep = 0,
  healthpoints = 0.0,
  maxHealthPoints = 0.0,
  slowFallVelocity = 0.0,
  characterDone = false,
  alive = false,
  cursorDown = false,
  resultList = nil,
  characterId = 0,
  scorePoints = 0,
  prematureJump = false
}

function Character:addScorePoints(value)
  self.scorePoints = self.scorePoints + value
end

function Character:getScorePoints()
  return self.scorePoints
end

function Character:setScore(value)
  self.scorePoints = value
end

function Character:setGroundLevel(value)
  self.groundLevel = value
end

function Character:getStateName()
  return self.characterState
end

function Character:getGameStarted()
  return self.gameStarted
end

function Character:isDead()
  return self.alive
end

function Character:init(resultList, characterId, texSheet, textureName)
  self.characterSprite = texSheet.createTexture(textureName)
  self.resultList = resultList
  self.characterId = characterId
  self.characterState = "idle"
  self.falling = false
  self.velocityDeathThreshold = 0.2
  self.breakForce = 0
  self.breakForceStep = 0.0007
  self.maxHealthPoints = 100.0
  self.healthpoints = self.maxHealthPoints
  self.gameStarted = false
  self.slowFallVelocity = 0.1
  self.characterDone = false
  self.alive = true
  self.maxVelocity = 0.9
  self.prematureJump = false
  self.acceleration = 0.1
end

function Character:getCharacterId()
  return self.characterId
end

function Character:reset(y)
  if not(self.alive) then
    self.healthpoints = self.maxHealthPoints
    self.alive = true
  end

  self.characterState = "idle"
  self.falling = false
  self.gameStarted = false
  self.characterDone = false
  self.y = y
  self.prematureJump = false
end

function Character:isDone()
  return self.characterDone
end

function Character:doPrematureJump()
  self.characterState = "prematureJump"
  self.prematureJump = true
end


-- States
function Character:prematureJumpDraw()
end

function Character:prematureJumpUpdate(deltaMs)
end

function Character:idleStateDraw()
end

function Character:idleStateUpdate(deltaMs)
  if self.cursorDown then
    if self.gameStarted == true then
      self.characterState = "fall"
    else
      --self.characterState = "fall"
    end
  end
end

function Character:disqualifyStateDraw()
end

function Character:disqualifyStateUpdate(deltaMs)
end

function Character:deathStateDraw()
end

apa = true
function Character:deathStateUpdate(deltaMs)
  self.alive = false
  self.velocity = 0
  if apa then
  self.x = self.x + math.sin(deltaMs) * 2
  apa = false
  else
  apa = true
  self.x = self.x - math.sin(deltaMs) * 2
  end

  if self.cursorDown then
    print("Died")
    self.characterDone = true
  end
end

function Character:groundStateUpdate(deltaMs)
  if self.velocity > self.velocityDeathThreshold then
    self.characterState = "death"
  else
    self.y = self.groundLevel

    local damage = (self.maxHealthPoints * (self.velocity / self.velocityDeathThreshold)) - (self.maxHealthPoints * (self.slowFallVelocity / self.velocityDeathThreshold))
    if damage > 1 then
      self.healthpoints = self.healthpoints - damage
    end

    if self.healthpoints > 0 then
      self.velocity = 0
      self.characterDone = true
    else
      self.characterState = "death"
    end
  end
end

function Character:groundStateDraw()
end

function Character:addToResultlist()
  table.insert(self.resultList, self.characterId)
end

function Character:fallStateUpdate(deltaMs)
  self.falling = true
  if self.velocity < self.maxVelocity then
    self.velocity = self.velocity + (self.acceleration * 0.16)
  end
  self.y = self.y + (self.velocity * 0.16)

  if self.y < self.groundLevel then
    self.y = self.groundLevel
    self:addToResultlist()
    self.characterState = "ground"
  end

  if self.cursorDown then
    self.characterState = "slowFall"
  end
end

function Character:fallStateDraw()
end


function Character:slowFallStateUpdate(deltaMs)
  if self.velocity > self.slowFallVelocity then
    self.velocity = self.velocity - self.breakForceStep * deltaMs
  end

  if self.y < self.groundLevel then
    self.y = self.groundLevel
    self:addToResultlist()
    self.characterState = "ground"
  end
end

function Character:slowFallStateDraw()
end

-- Get / set
function Character:getPosition()
  return self.x, self.y
end

function Character:setPosition(x, y)
  self.x = x
  self.y = y
end

function Character:setX(x)
  self.x = x
end

function Character:setY(y)
  self.y = y
end

function Character:getX()
  return self.x
end

function Character:getY()
  return self.y
end

function Character:getSpriteWidth()
  return self.characterSprite.getWidth()
end

function Character:getSpriteHeight()
  return self.characterSprite.getHeight()
end

function Character:draw()
  if self.characterState ~= nil then
    -- Ugly as fawk..
    if self.characterState == "idle" then
      self:idleStateDraw()
    elseif self.characterState == "disqualify" then
      self:disqualifyStateDraw()
    elseif self.characterState == "fall" then
      self:fallStateDraw()
    elseif self.characterState == "slowFall" then
      self:slowFallStateDraw()
    elseif self.characterState == "ground" then
      self:groundStateDraw()
    elseif self.characterState == "death" then
      self:deathStateDraw()
    elseif self.characterState == "prematureJump" then
      self:prematureJumpDraw()
    end
  end
  self.characterSprite.draw(self.x, self.y, 0, 0, 0, 0.75, 0.75)
end

function Character:update(deltaMs)
  if self.characterState ~= nil then
    -- Ugly as fawk..
    if self.characterState == "idle" then
      self:idleStateUpdate(deltaMs)
    elseif self.characterState == "disqualify" then
      self:disqualifyStateUpdate(deltaMs)
    elseif self.characterState == "fall" then
      self:fallStateUpdate(deltaMs)
    elseif self.characterState == "slowFall" then
      self:slowFallStateUpdate(deltaMs)
    elseif self.characterState == "ground" then
      self:groundStateUpdate(deltaMs)
    elseif self.characterState == "death" then
      self:deathStateUpdate(deltaMs)
    elseif self.characterState == "prematureJump" then
      self:prematureJumpUpdate(deltaMs)
    end
  end

  if self.falling then
  self.y = self.y - self.velocity * deltaMs
  end

end

function Character:setGameStarted(gameStarted)
  self.gameStarted = gameStarted
end

function Character:doInput(inputCursorDown)
  self.cursorDown = inputCursorDown
end

function Character:cd() 
  return self.cursorDown
end

function Character:percentageToGround()
  local range = (self.maxVelocity - self.slowFallVelocity)
  local rangeVel = (self.velocity - self.slowFallVelocity)
  local perc = rangeVel / range

  return perc
end
