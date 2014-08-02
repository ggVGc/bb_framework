framework = framework or {}

framework.Rect = {}


function framework.Rect.new(x, y, w, h)
  local M = {}
  M.x = x
  M.y = y
  M.w = w
  M.h = h

  M.collidesWith = function(other)
	return not (
		(M.y+M.h < other.y) or
		(M.y > other.y+other.h) or
		(M.x > other.x+other.w) or
		(M.x+M.w < other.x) )
  end


  M.containsPoint = function(x, y)
    return
      x > M.x and
      x < M.x + M.w and
      y > M.y and
      y < M.y + M.h
  end

  return M
end



