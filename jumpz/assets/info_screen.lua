

dofile("framework/input.lua")

InfoScreen = {}

function InfoScreen.new(texSheet, guiCam)
  local M = {}
  local inp = framework.Input.new()

  local bgImage = texSheet.createTexture("info_box.png", 780, 400)

  function M.update(deltaMs)
    inp.update()
    if inp.cursorPressed() then
      return ArcadeScreen
    end

  end

  function M.draw()
    guiCam:apply()
    bgImage.draw(guiCam:getWidth()/2, guiCam:getHeight()/2)
  end

  return M
end
