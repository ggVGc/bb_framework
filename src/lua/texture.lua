framework = framework or {}
framework.Texture = {}

function framework.Texture.new(tex)
  local M = {}

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
