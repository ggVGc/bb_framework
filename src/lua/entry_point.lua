

function loadfile(path, ignoreInvalid, errorReportOffset)
  path = path:gsub('%.moon', '.lua')
  errorReportOffset = errorReportOffset or 0
  local codeString = _c_framework.loadBytes(path, nil)
  if not codeString then
    if not ignoreInvalid then
      error ("Invalid file: "..path, 2+errorReportOffset)
    else
      return nil
    end
  end
  local ret, err = loadstring(codeString, path)
  if ret then
    return ret
  else
    error(err, 2+errorReportOffset)
  end
end

local function dofile_raw(path, ignoreInvalid)
  local f = loadfile(path, ignoreInvalid, 1);
  if f then
    return f()
  end
  return nil
end


function rewriteErrorMsg(errMsg)
  local ind1 = errMsg:find('"')
  if not ind1 then
    return errMsg
  end
  local ind2 = errMsg:find('"', ind1+1)
  local fileKey = errMsg:sub(ind1+1, ind2-1):gsub('%.lua','')
  ind1 = errMsg:find(':', ind2)
  ind2 = errMsg:find(':', ind1+1)
  local errNum = tonumber(errMsg:sub(ind1+1, ind2-1))
  local data = dofile_raw('moon_source_mappings.lua', true)
  local lineNum = nil
  if(data and data[fileKey]) then
    for _,entry in ipairs(data[fileKey]) do
      local luaLine, moonLine = entry[1], entry[2]
      if lineNum==nil then
        if errNum >= luaLine then lineNum = moonLine end
      else
        if errNum<luaLine then
          break
        else
          lineNum = moonLine
        end
      end
    end
    if lineNum then
      return errMsg:gsub(':'..tostring(errNum)..':', ':'..tostring(lineNum)..':'):gsub('%.lua', '.moon')
    end
  end
  return errMsg
end


local function doCall(func)
  local e = nil
  local function handler(err)
    print(debug.traceback(rewriteErrorMsg(err), 2))
    _c_framework.setAppBroken(1);
  end
  local ret;
  xpcall(function()
    ret = func()
  end, handler)

  if e then
  end

  return ret;
end


function dofile(path) 
  return doCall(function()
    return dofile_raw(path)
  end)
end

--[[
function require(arg)
  local p = 'framework/'..arg:gsub('%.', '/')..'.lua'
  print(p)
  return dofile(p)
end

dofile "framework/moon.lua"

]]

local strict = dofile("framework/strict.lua")
strict.make_all_strict(_G)

--Add Moses globally as undescore
_ = dofile("framework/libs/moses.lua");

framework = {}
dofile("framework/camera.lua");
dofile("framework/bitmap.lua")
dofile("framework/input.lua");
dofile("framework/texture_sheet.lua");
dofile("framework/input.lua");
dofile("framework/window.lua");
dofile("framework/rect.lua");
dofile("framework/extensions.lua");
dofile("framework/graphics.lua");
dofile("framework/bitmap_animation.moon");
dofile("framework/vector.lua");
dofile("framework/level.moon");

dofile("main.lua")
--dofile("framework/test/bitmap_animation_test.moon")
--dofile("bitmap_test.lua")
--dofile("framework/test/xmltest.lua")
--dofile("framework/test/texture_sheet_test.lua")
--dofile("framework/test/input_test.lua")
--dofile("framework/test/screen_test.lua")
--dofile("framework/test/camera_test.lua")
--dofile("framework/test/vector_test.lua")

framework = framework or {}

local main

function framework.init()
  main = doCall(Main.new)
end


local running = true
framework.exit = function()
  running = false
end
function framework.doFrame(deltaMs)
  local d
  if deltaMs>0 then d = deltaMs else d = 0 end
  if running and _c_framework.isAppBroken() == 0 then
    doCall(function()
      main.doFrame(d)
    end)
  else
    return 1
  end
end
