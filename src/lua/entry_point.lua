

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



local trim
trim = function(str)
  return str:match("^%s*(.-)%s*$")
end

local split
split = function(str, delim)
  if str == "" then
    return { }
  end
  str = str .. delim
  local _accum_0 = { }
  local _len_0 = 1
  for m in str:gmatch("(.-)" .. delim) do
    _accum_0[_len_0] = m
    _len_0 = _len_0 + 1
  end
  return _accum_0
end


local lineTab = {}

local rewrite_traceback
rewrite_traceback = function(text, err)
  local line_tables = lineTab
  local V, S, Ct, C
  V, S, Ct, C = lpeg.V, lpeg.S, lpeg.Ct, lpeg.C
  local header_text = "stack traceback:"
  local Header, Line = V("Header"), V("Line")
  local Break = lpeg.S("\n")
  local g = lpeg.P({
    Header,
    Header = header_text * Break * Ct(Line ^ 1),
    Line = "\t" * C((1 - Break) ^ 0) * (Break + -1)
  })
  local cache = { }
  local rewrite_single
  rewrite_single = function(trace)
    local fname, line, msg = trace:match('^(.-):(%d+): (.*)$')
    local tbl = line_tables["@" .. tostring(fname)]
    if fname and tbl then
      return table.concat({
        fname,
        ":",
        reverse_line_number(fname, tbl, line, cache),
        ": ",
        "(",
        line,
        ") ",
        msg
      })
    else
      return trace
    end
  end
  err = rewrite_single(err)
  local match = g:match(text)
  if not (match) then
    return nil
  end
  for i, trace in ipairs(match) do
    match[i] = rewrite_single(trace)
  end
  return table.concat({
    "moon: " .. err,
    header_text,
    "\t" .. table.concat(match, "\n\t")
  }, "\n")
end



local truncate_traceback
truncate_traceback = function(traceback, chunk_func)
  if chunk_func == nil then
    chunk_func = "moonscript_chunk"
  end
  traceback = split(traceback, "\n")
  local stop = #traceback
  while stop > 1 do
    if traceback[stop]:match(chunk_func) then
      break
    end
    stop = stop - 1
  end
  do
    local _accum_0 = { }
    local _len_0 = 1
    local _max_0 = stop
    for _index_0 = 1, _max_0 < 0 and #traceback + _max_0 or _max_0 do
      local t = traceback[_index_0]
      _accum_0[_len_0] = t
      _len_0 = _len_0 + 1
    end
    traceback = _accum_0
  end
  local rep = "function '" .. chunk_func .. "'"
  traceback[#traceback] = traceback[#traceback]:gsub(rep, "main chunk")
  return table.concat(traceback, "\n")
end

local function doCall(func)
  local err = nil
  local trace
  local function handler(e)
    err = e
    trace = debug.traceback('', 2)
    _c_framework.setAppBroken(1);
  end

  local ret;
  xpcall(function()
    ret = func()
  end, handler)

  if err then
      --local truncated = truncate_traceback(trim(trace))
      --local rewritten = rewrite_traceback(truncated, err)
      --local rewritten = rewrite_traceback(truncated, err)


      local rewritten = rewriteErrorMsg(err)..'\n'..trace

      if rewritten then
        print 'printing rewritten'
        print(rewritten)
      else
        print 'failed rewrite'
          -- faield to rewrite, show original
          print(err..'\n'..trim(trace))
      end
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

fun = dofile("framework/libs/fun.lua");

framework = {}
dofile("framework/globals.moon");
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
