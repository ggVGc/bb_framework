
Main = {}
function Main.new()
  M = {}


  function gameFunc()
    print "skeleton"
    M.doFrame = function() end
  end


  M.doFrame = gameFunc

  return M
end
