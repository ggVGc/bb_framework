
local Inp
Inp = {
  MAX_KEYS = 512,
  MAX_CURSORS = 5,

  State = {
    new=function()
      local o = {x=0, y=0, cursorStates={}, keysDown={}}
      for i=1,Inp.MAX_CURSORS do
        o.cursorStates[i] = {x=0,y=0,down=false}
      end
      return o
    end,
    copy = function(dst, src)
      dst.x, dst.y = src.x, src.y
      for k in pairs (src.keysDown) do
        dst.keysDown[k] = src.keysDown[k]
      end
      for i=1,Inp.MAX_CURSORS do
        local ds = dst.cursorStates[i]
        local ss = src.cursorStates[i]
        ds.x, ds.y, ds.down = ss.x, ss.y, ss.down
      end
    end
  },
  
  setCursorPos = function(index, x, y)
    if index <= Inp.MAX_CURSORS then 
      local s = Inp.curState.cursorStates[index+1]
      s.x, s.y = x, y
    end
  end,
  setCursorDownState = function(index, down)
    if index <= Inp.MAX_CURSORS then 
      Inp.curState.cursorStates[index+1].down = down
    end
  end,
  setKeyPressed = function(code)
    Inp.curState.keysDown[code] = true
  end,
  setKeyReleased = function(code)
    Inp.curState.keysDown[code] = nil
  end,



  cursorDown = function(index) return Inp.curState.cursorStates[index or 1].down end,
  cursorX= function(index) return Inp.curState.cursorStates[index or 1].x/framework.Window.getWidth() end,
  cursorY= function(index) return 1-(Inp.curState.cursorStates[index or 1].y/framework.Window.getHeight()) end,
  keyDown= function(code) return Inp.curState.keysDown[index or 1] end,
  charDown= function(char) return Inp.keyDown(string.byte(char))end,


  new=function()
    local M = {}


    local lastState = Inp.State.new()
    local thisState = Inp.State.new()

    function M.update()
      Inp.State.copy(lastState, thisState)
      Inp.State.copy(thisState, Inp.curState)
    end

    function M.cursorPressed(index)
      return not(lastState.cursorStates[index or 1].down) and thisState.cursorStates[index or 1].down
    end

    function M.anyCursorPressed()
      for i=1,Inp.MAX_CURSORS do
        if M.cursorPressed(i) then
          return i
        end
      end
      return nil
    end

    function M.eachCursorPress(func)
      for i=1,Inp.MAX_CURSORS do
        if M.cursorPressed(i) then
          func(Inp.cursorX(i), Inp.cursorY(i), i)
        end
      end
    end

    function M.cursorReleased(index)
      return lastState.cursorStates[index or 1].down and not(thisState.cursorStates[index or 1].down)
    end

    function M.keyPressed(code)
      return not(lastState.keysDown[code]) and thisState.keysDown[code]
    end

    function M.charPressed(ch)
      return M.keyPressed(string.byte(ch))
    end

    return M
  end
}

Inp.curState = Inp.State.new()


framework = framework or {}
framework.Input = Inp


