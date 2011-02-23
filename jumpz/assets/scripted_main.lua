


local API = {}

function API.trace(s)
  print(s)
end


API.Context = {}

function API.Context.new()
  local M = {}

  M.texSheet = framework.TextureSheet.fromFiles("data/sheet.png", "data/sheet.txt", "error.png")

  local env = {}

  for k, v in pairs(API) do
    if k ~= "Context" then
      env[k] = v
    end
  end

  local curScript = nil

  env.dostring = function(str)
    API.Context.current = M
    local f = loadstring(str)
    setfenv(f, env)
    curScript = coroutine.create(f)
    local ret, val = coroutine.resume(curScript)
    if not ret then
      print(val)
    end

  end

  env.dofile = function(path) 
    local s = loadfile(path)
    env.dostring(s)
  end

  env.open = function(obj)
    for k, v in pairs(obj) do
      env[k] = v
    end
  end

  local timeout = 0

  env.wait = function(milliseconds)
    timeout = milliseconds
    coroutine.yield()
  end

  M.dofile = env.dofile;
  M.dostring = env.dostring;


  M.camera = framework.Camera.createDefault()
  M.objects = {}


  function M.doFrame(deltaMs)
    if timeout > 0 then
      timeout = timeout - deltaMs
      if timeout <= 0 then
        local ret, val = coroutine.resume(curScript)
        if not ret then
          print(val)
        end
      end
    end

    M.camera.apply()
    for k, v in pairs(M.objects) do
      v.doFrame(deltaMs)
    end
  end

  return M
end


API.Arcade = {}

API.Arcade.Character = {}
local Char = API.Arcade.Character

function Char.new()
  local M = {}

  function M.setPos(x, y)
  end


  return M
end

API.Camera = {}
local Cam = API.Camera

function Cam.new()
  local M = {}

  function M.setActive()
    API.Context.camera = M
  end

  return M
end


API.Spammer = {}
function API.Spammer.new(str)
  local M = {}
  function M.doFrame()
    print(str)
  end
  table.insert(API.Context.current.objects, M)
  return M
end


API.Image = {}

function API.Image.new(path, expWidth, expHeight)
  local M = {}
  local tex = API.Context.current.texSheet.createTexture(path, expWidth, expHeight)
  local visible = true
  local pos = {x=0,y=0}

  function M.setX(v)
    pos.x = v
  end

  function M.setY(v)
    pos.y = v
  end

  function M.setPos(x, y)
    pos.x = x
    pos.y = y
  end

  function M.show()
    visible = true
  end

  function M.hide()
    visible = false
  end

  function M.doFrame()
    if visible then
      tex.draw(pos.x, pos.y)
    end
  end

  table.insert(API.Context.current.objects, M)
  return M
end




Main = {}

function Main.new()
  local M = {}
  local ctx = API.Context.new()

  function init()
    ctx.dofile("main_script.lua")
  end

  local a = 2
  function M.doFrame(deltaMs)
    if deltaMs > 100 then
      deltaMs = 100
    elseif deltaMs < 0 then
      error("Delta is negative")
    end
    ctx.doFrame(deltaMs)
  end

  init()
  return M
end


