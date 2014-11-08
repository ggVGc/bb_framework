framework = framework or {}
local Tex
Tex = {
bmDataCache:{}
new: (bmData, x, y, w, h)->
  M = {}
  with M
    .tex = _c_framework.Texture()

    tmpRect = _c_framework.Rect()
    _c_framework.rectInit(tmpRect, x/bmData.width,y/bmData.height,w/bmData.width, h/bmData.height)
    _c_framework.textureInit(.tex, bmData, tmpRect)

    setmetatable M, with {}
      .__index=(t,k)-> switch k
        when "width"
          M.tex.width
        when "height"
          M.tex.height


    tmpMat = _c_framework.Matrix2!
    .draw=(m, opacity)->
      _c_framework.Matrix2_copy(tmpMat, m)
      _c_framework.Matrix2_append(tmpMat, .tex.width, 0, 0, .tex.height, 0, 0)
      _c_framework.quadDrawTexAlpha(.tex, tmpMat, opacity and opacity or 1)

    .drawAt = (x,y)->
      _c_framework.Matrix2_init(tmpMat, 1, 0, 0, 1, x, y)
      _c_framework.Matrix2_append(tmpMat, .tex.width, 0, 0, .tex.height, 0, 0)
      _c_framework.quadDrawTex .tex, tmpMat


bmDataFromFile: (path, errorOnInvalid=true)->
  path = Tex.fixPath path
  local bmData
  if not Tex.bmDataCache[path]
    imageData = _c_framework.loadImage(path)
    if not imageData
      if errorOnInvalid
        error("Invalid image file: "..path)
      return nil
    bmData = _c_framework.BitmapData()
    _c_framework.bitmapDataInit(bmData, imageData)
    _c_framework.rawBitmapDataCleanup(imageData)
    Tex.bmDataCache[path] = bmData
  else
    bmData = Tex.bmDataCache[path]
  return bmData

fromFile: (path, errorOnInvalid=true)->
  bmData = Tex.bmDataFromFile path, errorOnInvalid
  Tex.new(bmData, 0, 0, bmData.width, bmData.height)

fixPath: (path) ->
  if not string.endsWith path, '.png'
    path = path..'.png'
  path

rebuildCachedTextures: ->
  for k,v in pairs Tex.bmDataCache
    print "Reloading", k
    imageData = _c_framework.loadImage(k)
    _c_framework.bitmapDataInit(v, imageData)
    _c_framework.rawBitmapDataCleanup(imageData)

freeCachedTextures: ->
  for k,v in pairs Tex.bmDataCache
    print "freeing", k
    _c_framework.bitmapDataCleanup(v)

}

framework.Texture = Tex
