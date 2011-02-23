dofile("menustate.lua")
dofile("arcadestate.lua")

currentState = nil

function changeGameState(state, texSheet)
  if currentState then
    currentState:onExit()
  end

  if state == "menu_state" then
    currentState = MenuState:new()
  elseif state == "arcade_state" then
    currentState = ArcadeState:new()
  end
  
  currentState:onLoad(texSheet)
end

function updateGameState(deltaMs)
  if currentState then
    currentState:update(deltaMs)
  end
end

function drawGameState()
  if currentState then
    currentState:draw()
  end
end
