

function loadfile(path)
  local codeString = _c_framework.loadBytes(path, nil)
  local ret, err = loadstring(codeString, path)
  if ret then
    return ret
  else
    print(err)
    return nil
  end
end

function dofile(path)
  local f = loadfile(path);
  if f then
    return f()
  end
  return nil
end

local strict = dofile("framework/strict.lua")
strict.make_all_strict(_G)


dofile("framework/camera.lua");
dofile("framework/bitmap.lua")
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
