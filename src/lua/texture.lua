



framework = framework or {}

framework.Texture = {}

function framework.Texture.new(tex)
  local M = {}

  function M.draw(x, y, pivotX, pivotY, rot, scaleX, scaleY)

    local w = scaleX or 1
    local h = scaleY or 1

    _c_framework.quadDraw(
    x or 0, y or 0,
    (scaleX or 1)*tex.width, (scaleY or 1)*tex.height, 
    tex, rot or 0,
    pivotX or 0.5, pivotY or 0.5)
  end


  function M.getWidth()
    return tex.width
  end

  function M.getHeight()
    return tex.height
  end


  return M
end



