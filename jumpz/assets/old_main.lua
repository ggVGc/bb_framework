
dofile("framework/window.lua")
dofile("camera.lua")
dofile("root_screen.lua")
dofile("framework/streaming_audio.lua")

Main = {}

function Main.new()
  local M = {}
  local fpsCounter = nil
  local rootScreen = nil


  function init()
    local audio = framework.StreamingAudio.new("data/tune.ogg")
    audio.setLooping(true)
    audio.play()

    local aspect = framework.Window.getHeight()/framework.Window.getWidth()

    texSheet = framework.TextureSheet.fromFiles("data/sheet.png", "data/sheet.txt", "error.png")
 
    rootScreen = RootScreen.new()

    --screens[SplashScreen] = SplashScreen.new(texSheet, 5000, camera:getWidth(), camera:getHeight())
    --screens[MainScreen] = MainScreen.new(texSheet, camera, uiCamera)
    --screens[ArcadeScreen] = ArcadeScreen.new(texSheet, camera, uiCamera)
    --screens[InfoScreen] = InfoScreen.new(texSheet, uiCamera)

  end

  function M.doFrame(deltaMs)
    rootScreen.frame(deltaMs)
  end

  init()
  return M
end
