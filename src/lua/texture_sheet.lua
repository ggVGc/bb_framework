dofile("framework/xml.lua")
dofile("framework/xml_handler.lua")
dofile("framework/xml_pretty.lua")
dofile("framework/texture.lua")
dofile("framework/string_extensions.lua")

framework = framework or {}
framework.TextureSheet = {}

function framework.TextureSheet.new(rectMap, bmData, errorTexPath)
  local M = {}
  local cache = {}

  function M.exists(path)
    path = framework.Texture.fixPath(path)
    return rectMap[path] ~= nil
  end

  function M.createTexture(path, expectedWidth, expectedHeight)
    path = framework.Texture.fixPath(path)
    local texRect = rectMap[path]
    if not texRect then
      if not(errorTexPath == nil) then
        texRect = rectMap[errorTexPath] -- Warning: This will actually get modified
      else
        error("Invalid key: "..path)
      end
    else 
      if expectedWidth == nil then expectedWidth = texRect.w end
      if expectedHeight == nil then expectedHeight = texRect.h end

      if math.floor(expectedWidth) ~= math.floor(texRect.w) then  
        error("expected width: "..expectedWidth.." does not match actual width: "..(texRect.w))
      end
      if math.floor(expectedHeight) ~= math.floor(texRect.h) then
        error("expected height: "..expectedHeight.." does not match actual height: "..(texRect.h))
      end
    end

    local ret = cache[path]
    if not ret then
      local w = texRect.width
      local h = texRect.height
      if expectedHeight ~= nil then w = expectedWidth end
      if expectedHeight ~= nil then h = expectedHeight end
      ret = framework.Texture.new(bmData, texRect.x, texRect.y, w, h) 
      cache[path] = ret
    end
    return ret
  end

  return M
end


function framework.TextureSheet.fromFiles(imagePath, layoutInfoPath, errorTexPath)
  local layoutData = _c_framework.loadText(layoutInfoPath)
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
    

  local rectMap = {}
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


      local rect = {}
      rect = {
        x = x,
        w = w,
        h = h
      }
      rect.y = bmData.height - y- rect.h 
      rectMap[name] = rect
    end
  end



  return framework.TextureSheet.new(rectMap, bmData, errorTexPath)
end




