local function newCursorState()
  return {x=0,y=0,down=false}
end

local Inp
Inp = {
  paused = false,
  MAX_KEYS = 512,

  State = {
    new=function()
      local o = {x=0, y=0, cursorStates={}, keysDown={}}
      o.cursorStates[1] = newCursorState()
      return o
    end,
    copy = function(dst, src)
      dst.x, dst.y = src.x, src.y
      for k in pairs(dst.keysDown) do
        dst.keysDown[k] = nil
      end
      for k in pairs (src.keysDown) do
        dst.keysDown[k] = src.keysDown[k]
      end
      for i=1,#src.cursorStates do
        if not dst.cursorStates[i] then
          dst.cursorStates[i] = newCursorState()
        end
        local ds = dst.cursorStates[i]
        local ss = src.cursorStates[i]
        ds.x, ds.y, ds.down = ss.x, ss.y, ss.down
      end
    end
  },
  
  setCursorPos = function(index, x, y)
    if Inp.paused then return end
    --print ('Cursor pos, index:', index, 'x:',x,'y:',y)
    --if index <= Inp.MAX_CURSORS then 
    local ind = index+1;
    if not Inp.curState.cursorStates[ind] then
      Inp.curState.cursorStates[ind] = newCursorState()
    end
    local s = Inp.curState.cursorStates[ind]
    s.x, s.y = x, y
    --end
  end,
  setCursorDownState = function(index, down)
    if Inp.paused then return end
    --print ('Cursor down, index:', index, 'down:', down)
    --if index <= Inp.MAX_CURSORS then 
    local ind = index+1;
    if not Inp.curState.cursorStates[ind] then
      Inp.curState.cursorStates[ind] = newCursorState()
    end
    Inp.curState.cursorStates[ind].down = down
    --end
  end,
  setKeyPressed = function(code)
    if Inp.paused then return end
    Inp.curState.keysDown[code] = true
  end,
  setKeyReleased = function(code)
    if Inp.paused then return end
    Inp.curState.keysDown[code] = nil
  end,



  cursorDown = function(index) return Inp.curState.cursorStates[index or 1].down end,
  cursorX= function(index) return Inp.curState.cursorStates[index or 1].x/framework.Window.getWidth() end,
  cursorY= function(index) return 1-(Inp.curState.cursorStates[index or 1].y/framework.Window.getHeight()) end,
  keyDown= function(code) return Inp.curState.keysDown[index or 1] end,
  charDown= function(char) return Inp.keyDown(string.byte(char))end,

  cursorCount= function() return #Inp.curState.cursorStates end,

  anyCursorDown = function(index)
    for s in Inp.curState.cursorStates do
      if s.down then
        return i
      end
    end
    return nil
  end,

  new=function()
    local M = {}

    local lastState = Inp.State.new()
    local thisState = Inp.State.new()

    function M.update()
      Inp.State.copy(lastState, thisState)
      Inp.State.copy(thisState, Inp.curState)
    end


    function M.anyCursorPressed()
      for i=1,#thisState.cursorStates do
        if M.cursorPressed(i) then
          return i
        end
      end
      return nil
    end
    function M.anyCursorReleased()
      for i=1,#thisState.cursorStates do
        if M.cursorReleased(i) then
          return i
        end
      end
      return nil
    end

    function M.eachCursorPress(func)
      for i=1,#thisState.cursorStates do
        if M.cursorPressed(i) then
          func(Inp.cursorX(i), Inp.cursorY(i), i)
        end
      end
    end

    function M.cursorPressed(index)
      local ind = index or 1
      return (not lastState.cursorStates[ind] or not lastState.cursorStates[ind].down) and thisState.cursorStates[ind].down
    end

    function M.cursorReleased(index)
      local ind = index or 1
      return lastState.cursorStates[ind] and lastState.cursorStates[ind].down and not thisState.cursorStates[ind].down
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


