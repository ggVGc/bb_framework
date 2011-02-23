Class = {}
function Class:new(o)
  local object = o or {}
  setmetatable(object, self)
  self.__index = self
  return object
end
