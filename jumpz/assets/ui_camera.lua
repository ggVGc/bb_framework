
dofile("framework/camera.lua")

UICamera = {}

function UICamera.new()
  return framework.Camera.new(framework.Window.getWidth(), framework.Window.getHeight())
end


