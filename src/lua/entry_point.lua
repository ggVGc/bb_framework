
if jit then 
  jit.off()
end

-- Be compatible with lua 5.2
loadstring = load


--[[
local oldPrint = print
function print(...)
  local arg = {...}
  local s
  for i=1,#arg do
    s = s and s or ''
    local v = arg[i]
    if v == false then
      v = 'false'
    end
    s = s..(v and tostring(v) or 'nil')..'\t'
  end
  if s == false then
    s = 'false'
  end
  oldPrint(s and s or 'nil')
end

]]

function loadfile(path, ignoreInvalid, errorReportOffset)
  path = path:gsub('%.moon', '.lua')
  errorReportOffset = errorReportOffset or 0
  local codeString = _c_framework.loadText(path)
  if not codeString then
    if not ignoreInvalid then
      error ("Invalid file: "..path, 2+errorReportOffset)
    else
      return nil
    end
  end
  local ret, err = load(codeString, path)
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

local callFunc
local err = nil
local trace
local ret
local function xpCallBody()
  ret = callFunc()
end

local function handler(e)
  err = e
  trace = debug.traceback('', 2)
  _c_framework.setAppBroken(1);
end

local function doCall(func)
  callFunc = func
  xpcall(xpCallBody, handler)

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


function dofile(path, ...) 
  if path == 'debug' then
    require 'debug'
    return
  end
  if select('#', ...) > 0 then
    dofile_raw(path)
    return dofile(...)
  else
    if type(path) == 'table' then
      local ret
      for _,p in pairs(path) do
        ret = dofile_raw(p)
      end
      return ret
    else
      return dofile_raw(path)
    end
  end
end

--[[
function require(arg)
  local p = 'framework/'..arg:gsub('%.', '/')..'.lua'
  print(p)
  return dofile(p)
end

dofile "framework/moon.lua"

]]



-- Stay compatible with 5.1 and 5.2
unpack = unpack or table.unpack

--Add Moses globally as underscore
do 
  local oldUnpack = unpack
  if oldUnpack then
    unpack = table.unpack
  end
   _ = dofile "framework/libs/moses.lua";
   if oldUnpack then
     unpack = oldUnpack
   end
end


local strict = dofile("framework/strict.lua")

fun = dofile "framework/libs/fun.lua";

framework = {}
framework.tserialize = dofile('framework/tserialize.lua').tserialize
dofile({"framework/globals.moon",
"framework/instanceof.lua",
"framework/string_additions.moon",
"framework/camera.lua",
"framework/bitmap.lua",
"framework/input.lua",
"framework/texture_sheet.lua",
"framework/input.lua",
"framework/window.lua",
"framework/rect.lua",
"framework/extensions.lua",
"framework/graphics.lua",
"framework/bitmap_animation.moon",
"framework/vector.lua",
"framework/level.moon",
'framework/draw_states.moon',
'framework/asset_loader.moon',
'framework/font.moon',
'framework/tween/tween.moon',
'framework/tween/timeline.moon',
'framework/easel/ticker.moon',
'framework/easel/matrix2d.moon',
'framework/easel/display_object.moon',
'framework/easel/cjs_bitmap.moon',
'framework/easel/cjs_button.moon',
'framework/easel/container.moon',
'framework/easel/movie_clip.moon',
'framework/streaming_audio.lua',
'framework/ads.moon',
'framework/data_store.moon',
'framework/iap.moon',
'framework/fps_counter.lua',
})

dofile "main.moon"
--dofile("framework/test/temp_test.moon")
--dofile("framework/test/sheet_mem_test.moon")
--dofile("framework/test/parent_test.moon")
--dofile("framework/test/async_audioload_test.moon")
--dofile("framework/test/movie_clip_mem_test.moon")
--dofile("framework/test/display_objects_test.moon")
--dofile("framework/test/export_mc_anim_test.moon")
--dofile("framework/test/movie_clip_test.moon")
--dofile("framework/test/timeline_test.moon")
--dofile("framework/test/tween_test.moon")
--dofile("framework/test/bitmap_animation_test.moon")
--dofile("bitmap_test.lua")
--dofile("framework/test/xmltest.lua")
--dofile("framework/test/texture_sheet_test.lua")
--dofile("framework/test/input_test.lua")
--dofile("framework/test/screen_test.lua")
--dofile("framework/test/camera_test.lua")
--dofile("framework/test/vector_test.lua")

framework = framework or {}
framework.cjs = framework.cjs or {}

local main
local fps = FpsCounter.new()

function fromhex(str)
  return (str:gsub('..', function (cc)
    return string.char(tonumber(cc, 16))
  end))
end


local freezeFrameCount = 0
function framework.init(wasSuspended)
  framework.DataStore.reload()
  main = doCall(Main.new)
  freezeFrameCount = 2
  collectgarbage()
  collectgarbage 'stop'
end


local MEM_CHECK_INTERVAL = 1
local MAX_MEM_TRIGGER_GC = 35000
local lastMem=0
local frameDelta
local memCheckCounter = 0

local dDeltaBuffer = 0
local dFrameDeltaRemainingsAccumulated = 0
local dVsyncRefreshRate_p = _c_framework.getScreenRefreshRate() or 60
if dVsyncRefreshRate_p <=0 or dVsyncRefreshRate_p >120 then
  dVsyncRefreshRate_p = 60
end
print("Refresh rate: ", dVsyncRefreshRate_p)
if dVsyncRefreshRate_p > 80 then
  dVsyncRefreshRate_p = dVsyncRefreshRate_p/2
end
print("Frame render rate", dVsyncRefreshRate_p)

local function smoothDelta(inDelta)
  local dDelta_p = inDelta+dDeltaBuffer
  local frameCount = (dDelta_p * dVsyncRefreshRate_p + 1)
  if( frameCount <= 0 )then
    frameCount = 1
  end
  local dOldDelta = dDelta_p
  dDelta_p = frameCount / dVsyncRefreshRate_p
  dDeltaBuffer = dOldDelta - dDelta_p;
  return dDelta_p
end

local m_dFixedTimeStep = 100/30


local function frameFunc()
  fps.update(frameDelta)
  local dDeltaSeconds = smoothDelta(frameDelta)
  if dDeltaSeconds>100 then
    dDeltaSeconds = 1
  end

  dFrameDeltaRemainingsAccumulated = dFrameDeltaRemainingsAccumulated+dDeltaSeconds
  local dd = 0

  while dFrameDeltaRemainingsAccumulated>=m_dFixedTimeStep do
    dFrameDeltaRemainingsAccumulated = dFrameDeltaRemainingsAccumulated-m_dFixedTimeStep
    dd = dd+m_dFixedTimeStep
  end
  if dd>0 then
    main.update(dd)
  end
  framework.cjs.Bitmap.drawCounter = 0
  main.draw()
  if fps.hasNew() then
    print ( 'fps: '..fps.current(), 'B: '..framework.cjs.Bitmap.drawCounter, 'D: '.._c_framework.getDrawCallCount(), 'T: '..framework.MovieClip.tickCount)
    framework.MovieClip.tickCount = 0
  end
  memCheckCounter=memCheckCounter+frameDelta
  if memCheckCounter>MEM_CHECK_INTERVAL*1000 then
    memCheckCounter = 0
    local thisMem = collectgarbage 'count'
    print ('M: '..math.floor(thisMem).." ("..math.floor((thisMem-lastMem)/MEM_CHECK_INTERVAL)..")")
    lastMem = thisMem
    if thisMem > MAX_MEM_TRIGGER_GC then
      collectgarbage()
      --collectgarbage('stop')
    end
  end
end

local running = true
framework.exit = function()
  running = false
end

function framework.doFrame(deltaMs)
  if deltaMs>0 then frameDelta = deltaMs else frameDelta = 0 end
  if running and _c_framework.isAppBroken() == 0 then
    if freezeFrameCount>0 then
      freezeFrameCount = freezeFrameCount-1
      frameDelta = 0
    end
    doCall(frameFunc)
  else
    return 1
  end
end

function framework.suspend()
  if main and main.suspend then
    main.suspend()
  end
end

function framework.reloadTextures()
  print 'Reloading textures'
  framework.Texture.rebuildCachedTextures()
end


-- TODO: This is a total hack...
-- At some point the user should be able to set max dimensions for 
-- the scene, and anchor to top/bottom/left/right, and this should be done
-- automatically
function framework.setVisibleWindowHeight(h)
  print("Setting top cutoff", h)
  _c_framework.setScissor(0, 0, framework.Window.getWidth(), h)
end


strict.make_all_strict(_G)
