


framework = framework or {}

framework.Camera = {}

function framework.Camera.new(width, height)
  local M = {}
  local cam = _c_framework.Camera()

  _c_framework.cameraInit(cam, 0, 0, width, height)


  local mt = {}

  mt.__index = function(table, key)
    if key == "x" then
      return cam.posX
    elseif key == "y" then
      return cam.posY
    elseif key == "width" then
      return cam.width 
    elseif key == "height" then
      return cam.height 
    end
  end

  mt.__newindex = function(table, key, value)
    if key == "x" then
      cam.posX = value
    elseif key == "y" then
      cam.posY = value
    elseif key == "width" then
      cam.width = value
    elseif key == "height" then
      cam.height = value
    end
  end

  function M.apply()
    _c_framework.cameraSetActive(cam)
  end

  setmetatable(M, mt)


  return M
end


function framework.Camera.createDefault(width)
  local aspect = framework.Window.getHeight()/framework.Window.getWidth()
  print("Aspect: "..aspect)
  local w = width or (480*2)
  local h = w * aspect
  return framework.Camera.new(w, h)
end
