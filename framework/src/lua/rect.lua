
Rect = {}

function Rect.new(x, y, w, h)
  local M = {}
  M.x = x
  M.y = y
  M.w = w
  M.h = h

  return M
end


function Rect.contains(r, x, y)
  return
    x > r.x and
    x < r.x + r.w and
    y > r.y and
    y < r.y + r.h
end

