screen1 = {}
screen2 = {}
function screen1.new()
  local M = {}

  local myThing = 0


  function M.update(deltaMs)
    print "screen1 update"
    myThing = myThing + 1
    if myThing >10 then

    end
  end
  function M.draw()
  end
  return M
end

function screen2.new()
  local M = {}
  function M.update(deltaMs)
    print "screen2 update"
  end
  function M.draw()
  end
  return M
end


local cam
local rootScreen
local screens

function init()
  screens = {
    screen1.new(),
    screen2.new()
  }
  rootScreen = framework.CompositeScreen.new(screens)
  rootScreen.activate(1)
  rootScreen.activate(2)
end


function update(deltaMs)
end

function draw()
end
