
ArcadeCamera = {}

function ArcadeCamera.new()
  local M = {}
  local cam = framework.Camera.createDefault()


  M.widthBoundary = 0
  M.heightBoundary = 0

  function M.moveRelative(x, y)
    M.setPosition(M.x + x,M.y + y)
  end

  function M.setPosition(x, y)
    if x > M.widthBoundary+M.width then
      M.x = M.widthBoundary+M.width
    elseif x < 0 then
      M.x = 0
    else
      M.x = x
    end

    if y > M.heightBoundary-M.height then
      M.y = M.heightBoundary-M.height
    elseif y < 0 then
      M.y = 0
    else
      M.y = y
    end
  end


  local mt = {}
  function mt.__index(t, key)
    local ret = cam[key]
    if not(ret == nil) then
      return ret
    end
  end
  function mt.__newindex(t, key, val)
    if cam[key] then
      cam[key] = val
    end
  end
  setmetatable(M, mt)


  return M
end
