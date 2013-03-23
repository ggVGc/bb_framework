
framework = framework or {}

framework.ApplicationController = {}

function framework.ApplicationController.processControllers(activeControllers, modalStack, callMethods)
    if #modalStack ~= 0 then
      local c = modalStack[#modalStack];
      for k, v in ipairs(callMethods) do
        c[v]();
      end

    else
      for s in pairs(activeScreens) do
        activeScreens[i][methodName](deltaMs)
      end
    end

end

function framework.Screen.processScreens(activeScreens, modalScreens)
end


function framework.CompositeScreen.new()
  local M = {}
  local activeScreens = {}
  local modalStack = {}


  function callActiveScreens(methodName)

  end

  function M.update(deltaMs)
    callActiveScreens("update")
  end

  function M.draw()
    callActiveScreens("draw")
  end

  function M.pushModal(screen)
    table.insert(modalStack, screen)
  end

  function M.add(screen)
    table.insert(activeScreens, screen)
  end

  function M.remove(screen)
  end

  return M
end








