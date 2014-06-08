framework = framework or {}
framework.Texture = {}

function framework.Texture.new(bmData, x, y, w, h)
  local M = {}
  local tex = _c_framework.Texture()

  local tmpRect = _c_framework.Rect()
  _c_framework.rectInit(tmpRect, x/bmData.width, 
      y/bmData.height, w/bmData.width, h/bmData.height)
  _c_framework.textureInit(tex, bmData, tmpRect)

  M._bmDataRef = bmData --  keep ref to prevent GC

  local mt = {}
  function mt.__index(t,k)
    if k=="width" then return tex.width
    elseif k=="height" then return tex.height
    end
  end
  setmetatable(M,mt)

  function M.draw(x, y, pivotX, pivotY, rot, scaleX, scaleY)
    local w = scaleX or 1
    local h = scaleY or 1

    _c_framework.quadDrawTex(
      x or 0, y or 0,
      (scaleX or 1)*tex.width, (scaleY or 1)*tex.height, 
      tex, rot or 0,
      pivotX or 0.5, pivotY or 0.5)
  end

  return M
end
