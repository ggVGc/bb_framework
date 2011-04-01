

Main = {}



function Main.new()
  local M = {}

    local cam = framework.Camera.new(100, 100)

    print(cam.x)
    cam.x = 92
    print(cam.x)
    print(cam.width)
    print(cam.height)

  function M.update(deltaMs)

  end

  function M.draw()
  end
  return M
end


