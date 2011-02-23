
Main = {}

function Main.new()
  local M = {}

  function init()
    inp = framework.Input.new()
  end

  function M.update(deltaMs)
    inp.update()
    if inp.cursorPressed() then
      print("PRESS")
      print(inp.downPos.x.." "..inp.downPos.y)
    end
    if inp.cursorReleased() then
      print("RELEASE")
      print(inp.releasePos.x.." "..inp.releasePos.y)
    end
  end

  function M.draw()
  end

  init()
  return M
end
