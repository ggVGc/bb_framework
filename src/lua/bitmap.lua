framework = framework or {}

framework.Bitmap = {}

function framework.Bitmap.new(path)
  local M = {}
  
  function createTexture()
    local rawData = _c_framework.loadImage(path)
    local bmData = _c_framework.BitmapData()
    _c_framework.bitmapDataInit(bmData, rawData)
    _c_framework.rawBitmapDataCleanup(rawData)
    local rect = _c_framework.Rect()
    _c_framework.rectInit(rect, 0, 0, 1, 1)
    local tex = _c_framework.Texture()
    _c_framework.textureInit(tex, bmData, rect)
    return bmData, tex
  end

  M.bmData, M.tex = createTexture()

  function M.draw(x, y, rot, pivotX, pivotY)
    _c_framework.quadDrawTex(x or 0, y or 0, M.tex.width, M.tex.height, M.tex, rot or 0, pivotX or 0.5, pivotY or 0.5)
  end



  return M

end
