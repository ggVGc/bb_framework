
dofile("main_screen.lua")

RootScreen = {}

function RootScreen.new()
  local M = {}

  local MAIN = 0
  local GAME = 1

  local curState = MAIN

  local texSheet = 
    framework.TextureSheet.fromFiles("data/sheet.png", "data/sheet.txt", "error.png")

  local mainScreen = MainScreen.new(texSheet)
  local arcadeScreen = ArcadeScreen.new(texSheet)

  function M.frame(deltaMs)
    if curState == MAIN then
      mainScreen.frame(deltaMs)

      if mainScreen.startGame() then
        curState = GAME
      end

    elseif curState == GAME then 
      arcadeScreen.frame(deltaMs)
    end
  end
  return M
end

