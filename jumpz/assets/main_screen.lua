
dofile("arcade_screen.lua")
dofile("button.lua")
dofile("ui_camera.lua")
dofile("framework/camera.lua")

MainScreen = {}

function MainScreen.new(texSheet)
  local M = {}

  local uiCam = UICamera.new()
  local sceneCam = framework.Camera.createDefault()

  local background = texSheet.createTexture("menu_screen.png")
  local butTex = texSheet.createTexture("start_button.png", 100, 100)
  local butTexSpkOn = texSheet.createTexture("speaker_on_32.png")
  local butTexSpkOff = texSheet.createTexture("speaker_off_32.png")

  local startButton = Button.new(butTex, butTex)
  local spkButton = ToggleButton.new(butTexSpkOn, butTexSpkOff)

  local inp = framework.Input.new()

  local start = false
  local sound = false

  function M.frame(deltaMs)
    inp.update()

    sceneCam.apply()
    background.draw(sceneCam.width/2, sceneCam.height/2)

    uiCam.apply()
    if startButton.doo(0.5, 0.5, inp, uiCam) then
      start = true
    end
    
    if spkButton.doo(0.8, 0.1, inp, uiCam, sound) then
      sound = not(sound)
      print(sound)
    end
  end

  function M.startGame()
    return start
  end

  return M
end



