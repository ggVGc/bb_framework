
dofile("framework/rect.lua")
dofile("framework/window.lua")

Button = {}

function Button.new(defaultTex, downTex)
  local M = {}
  local rect = Rect.new(0, 0, 0, 0)

  if downTex == nil then
    downTex = defaultTex
  end

  function M.doo(x, y, inp, cam)
    rect.w = defaultTex.getWidth()/cam.width
    rect.h = defaultTex.getHeight()/cam.height
    rect.x = x - rect.w/2
    rect.y = y - rect.h/2
    drawX = x*cam.width
    drawY = y*cam.height

    if Rect.contains(rect, framework.Input.cursorX(), framework.Input.cursorY()) then
      if framework.Input.cursorDown() then 
        downTex.draw(drawX, drawY)
      else
        defaultTex.draw(drawX, drawY)
      end
      return inp.cursorReleased()
    else
      defaultTex.draw(drawX, drawY)
      return false
    end
  end

  return M

end

ToggleButton = {}

function ToggleButton.new(offTex, onTex)
  local M = {}
  local offButton = Button.new(offTex)
  local onButton = Button.new(onTex)

  function M.doo(x, y, inp, cam, pressed)
    drawX = x*cam.width
    drawY = y*cam.height
    if pressed then
      return onButton.doo(x, y, inp, cam)
    else
      return offButton.doo(x, y, inp, cam)
    end
  end

  return M
end


