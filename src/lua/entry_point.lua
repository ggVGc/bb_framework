

dofile("framework/bitmap.lua")
dofile("framework/camera.lua");
dofile("framework/input.lua");
dofile("framework/texture_sheet.lua");
dofile("framework/input.lua");
dofile("framework/window.lua");
dofile("framework/rect.lua");
dofile("framework/extensions.lua");
dofile("framework/graphics.lua");
dofile("framework/vector.lua");



dofile("main.lua")
--dofile("bitmap_jest.lua")
--dofile("framework/test/xmltest.lua")
--dofile("framework/test/texture_sheet_test.lua")
--dofile("framework/test/input_test.lua")
--dofile("framework/test/screen_test.lua")
--dofile("framework/test/camera_test.lua")
--dofile("framework/test/vector_test.lua")

framework = framework or {}

local main

function framework.init()
  main = Main.new()
end

function framework.doFrame(deltaMs)
  local d
  if deltaMs>0 then d = deltaMs else d = 0 end
  if _c_framework.isAppBroken() == 0 then
    main.doFrame(d)
  end
end
