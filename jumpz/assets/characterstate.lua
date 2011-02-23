CharacterState = Class:new{state_name="STATE_NAME"}

function CharacterState:getStateName()
  return self.name
end

function CharacterState:setStateName(state_name)
  self.state_name = state_name
end