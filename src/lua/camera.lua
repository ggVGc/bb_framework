
framework = framework or {}

framework.Camera = {}

framework.Camera.curAppliedHeight = nil


framework.Camera.MAX_HEIGHT = 640

function framework.Camera.new(width, height)
  local M = {x=0,y=0,width=width, height=height}
  local cam = _c_framework.Camera()

  _c_framework.cameraInit(cam, M.x, M.y, M.width, M.height)

  local mt = {}

  function M.apply()
    framework.Camera.curAppliedHeight = cam.height
    _c_framework.cameraSetActive(cam)
  end

  mt.__newindex = cam
  mt.__index = cam

  setmetatable(M, mt)
  return M
end

function framework.Camera.createDefault(width)
  local aspect = framework.Window.getHeight()/framework.Window.getWidth()
  return framework.Camera.new(width, width * aspect)
end
