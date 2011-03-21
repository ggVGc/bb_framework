
Main = {}

function Main.new()
  local M = {}

  function init()
    inp = framework.Input.new()
  end

  function M.doFrame(deltaMs)
    inp.update()
    if inp.cursorPressed() then
      print("PRESS")
      print(inp.downPos.x.." "..inp.downPos.y)
    end
    if inp.cursorReleased() then
      print("RELEASE")
      print(inp.releasePos.x.." "..inp.releasePos.y)
    end
    print(framework.Input.cursorX(), framework.Input.cursorY())
  end


  init()
  return M
end
