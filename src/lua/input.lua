framework = framework or {}

framework.Input = {
  MAX_KEYS = 512,

  cursorDown= function() return not(_c_framework.cursorDown()==0) end,
  cursorX= function() return _c_framework.cursorX()/framework.Window.getWidth() end,
  cursorY= function() return 1-(_c_framework.cursorY()/framework.Window.getHeight()) end,
  keyDown= function(code) return not(_c_framework.keyDown(code)==0) end,
  charDown= function(char) return framework.Input.keyDown(string.byte(char))end,

  State = {
    new=function()
      return {x=0, y=0, cursorDown=false, keysDown={}}
    end,
    copy = function(dst, src)
      dst.x, dst.y, dst.cursorDown = src.x, src.y, src.cursorDown
      for k in pairs (src.keysDown) do
        dst.keysDown[k] = src.keysDown[k]
      end
    end,
    reset = function(s, x, y, cursorDown)
      s.x, s.y, s.cursorDown = x,y,cursorDown
      for k in pairs (s.keysDown) do
        s.keysDown [k] = nil
      end
    end
  },

  new=function()
    local M = {}

    M.downPos = {x=0,y=0}
    M.releasePos = {x=0,y=0}

    local lastState = framework.Input.State.new()
    local curState = framework.Input.State.new()

    function M.update()
      framework.Input.State.copy(lastState, curState)
      framework.Input.State.reset(curState, framework.Input.cursorX(), framework.Input.cursorY(), framework.Input.cursorDown())

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

    function M.charPressed(ch)
      return M.keyPressed(string.byte(ch))
    end

    return M
  end
}


