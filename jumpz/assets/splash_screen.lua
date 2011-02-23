
SplashScreen = {}

function SplashScreen.new(texSheet, displayTime, screenW, screenH)
  local M = {}

  local bgImage = texSheet.createTexture("splash.png", screenW, screenH)
  local accumTime = 0

  function M.update(deltaMs)
    accumTime = accumTime + deltaMs
    if accumTime > displayTime then
      return MainScreen
    end
  end

  function M.draw()
    bgImage.draw(0, 0, 0, 0)
  end

  return M
end
