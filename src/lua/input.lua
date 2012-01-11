dofile("framework/Window.lua")

framework = framework or {}


framework.Input = 
{

  MAX_KEYS = 512,

  cursorDown= function() return not(_c_framework.cursorDown()==0) end,
  cursorX= function() return _c_framework.cursorX()/framework.Window.getWidth() end,
  cursorY= function() return 1-(_c_framework.cursorY()/framework.Window.getHeight()) end,
  keyDown= function(code) return not(_c_framework.keyDown(code)==0) end,
  charDown= function(char) return framework.Input.keyDown(string.byte(char))end,

  State = {
    new=function(x, y, cursorDown)
      return {x=x, y=y, cursorDown=cursorDown, keysDown={}}
    end
  },


  new=function()
    local M = {}

    M.downPos = {x=0,y=0}
    M.releasePos = {x=0,y=0}

    lastState = framework.Input.State.new()
    curState = framework.Input.State.new()

    function M.update()
      lastState = curState
      curState = framework.Input.State.new(framework.Input.cursorX(), framework.Input.cursorY(), framework.Input.cursorDown())
      if M.cursorPressed() then
        M.downPos = {x=curState.x, y=curState.y}
      end
      if M.cursorReleased() then
        M.releasePos = {x=curState.x, y=curState.y}
      end
      for x=0,framework.Input.MAX_KEYS do
        curState.keysDown[x] = framework.Input.keyDown(x)
      end
    end

    function M.cursorPressed()
      return not(lastState.cursorDown) and curState.cursorDown
    end

    function M.cursorReleased()
      return lastState.cursorDown and not(curState.cursorDown)
    end

    function M.keyPressed(code)
      return not(lastState.keysDown[code]) and curState.keysDown[code]
    end

    return M
  end
}


