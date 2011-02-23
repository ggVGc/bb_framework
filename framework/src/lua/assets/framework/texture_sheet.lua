dofile("framework/xml.lua")
dofile("framework/xml_handler.lua")
dofile("framework/xml_pretty.lua")
dofile("framework/texture.lua")
dofile("framework/string_extensions.lua")


framework = framework or {}



framework.TextureSheet = {}
framework.TextureSheet.mt = {}
function framework.TextureSheet.mt.foo()
  print("LKJL")
end


function framework.TextureSheet.new(map, errorTexPath)
  local M = {}
  setmetatable(M, framework.TextureSheet.mt)

  local tmpRect = _c_framework.Rect()


  function M.createTexture(path, expectedWidth, expectedHeight)
    local t = map[path]
    if not t then
      if not(errorTexPath == nil) then
        t = map[errorTexPath] -- Warning: This will actually get modified
      else
        error("Invalid key: "..path)
      end
    else 
      if expectedWidth == nil then expectedWidth = t.rect.w end
      if expectedHeight == nil then expectedHeight = t.rect.h end

      if math.floor(expectedWidth) ~= math.floor(t.rect.w) then  
        error("expected width: "..expectedWidth.." does not match actual width: "..(t.rect.w))
      end
      if math.floor(expectedHeight) ~= math.floor(t.rect.h) then
        error("expected height: "..expectedHeight.." does not match actual height: "..(t.rect.h))
      end
    end

    _c_framework.rectInit(tmpRect, t.rect.x/t.data.width, 
                            t.rect.y/t.data.height, t.rect.w/t.data.width, t.rect.h/t.data.height)

    local tex = _c_framework.Texture()
    _c_framework.textureInit(tex, t.data, tmpRect)
    if expectedHeight ~= nil then
      tex.width = expectedWidth
    end
    if expectedHeight ~= nil then
      tex.height = expectedHeight
    end

    return framework.Texture.new(tex)
  end

  return M
end


function framework.TextureSheet.fromFiles(imagePath, layoutInfoPath, errorTexPath)
  local layoutData = _c_framework.loadAscii(layoutInfoPath, nil)
  local imageData = _c_framework.loadImage(imagePath)
  local bmData = _c_framework.BitmapData()

  if imageData == nil then
    error("Invalid image file: "..imagePath)
  end

  if layoutData == "" or layoutData == nil then
    error("invalid layout file: "..layoutInfoPath)
  end

  _c_framework.bitmapDataInit(bmData, imageData)
  _c_framework.rawBitmapDataCleanup(imageData)
    

  map = {}
  local spl = layoutData:split(" ")
  for i, line in ipairs(layoutData:split("\n")) do 
    local spl = line:split(" ")
    if #spl == 6 then
      local name = spl[1]
      -- split 2 is the equals sign
      local x = tonumber(spl[3])
      local y = tonumber(spl[4])
      local w = tonumber(spl[5])
      local h = tonumber(spl[6])


      local t = {}
      t.data = bmData
      t.rect = {
        x = x,
        w = w,
        h = h
      }
      t.rect.y = bmData.height - y- t.rect.h 
      map[name] = t
    end
  end



  return framework.TextureSheet.new(map, errorTexPath)
end




