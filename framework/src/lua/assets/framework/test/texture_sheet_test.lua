dofile("framework/texture_sheet.lua")

Main = {}

function Main.new()
  local M = {}


  camera = framework.Camera.createDefault()

  sheet = framework.TextureSheet.fromFiles("data/sheet.png", "data/sheet.txt")
  tex = sheet.createTexture("test.png")

  --local rawData = _c_framework.loadImage("test.png")
  --bmData = _c_framework.BitmapData()
  --_c_framework.bitmapDataInit(bmData, rawData)
  --_c_framework.rawBitmapDataCleanup(rawData)
  --_c_framework.free(rawData)
  --local rect = _c_framework.Rect()
  --_c_framework.rectInit(rect, 0, 0, 1,1)
  --local t = _c_framework.Texture()
  --_c_framework.textureInit(t, bmData, rect)
  --tex = framework.Texture.new(t)

  function M.update(deltaMs)
  end

  function M.draw()
    camera.apply()
    tex.draw(0, 0, 0, 0, 0)
  end

  return M
end

function init()

end


function update(deltaMs)
end

function draw()
end
