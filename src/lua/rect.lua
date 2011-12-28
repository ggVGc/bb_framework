framework = framework or {}

framework.Rect = {}

function framework.Rect.new(x, y, w, h)
  local M = {}
  M.x = x
  M.y = y
  M.w = w
  M.h = h

  return M
end


function framework.Rect.containsPoint(rx, ry, rw, rh, x, y)
  return
    x > rx and
    x < rx + rw and
    y > ry and
    y < ry + rh
end

