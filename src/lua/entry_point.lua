
framework = framework or {}

function framework.init()
  print 'entry point init'
end

local running = true


framework.exit = function()
  running = false
end
function framework.doFrame(deltaMs)
  local d
  if deltaMs>0 then d = deltaMs else d = 0 end
  if running and _c_framework.isAppBroken() == 0 then
  else
    print 'broken'
    return 1
  end
end

