framework = framework or {}
framework.Texture = {
new: (bmData, x, y, w, h)->
  M = {}
  with M
    ._bmDataRef = bmData --  keep ref to prevent GC

    tex = _c_framework.Texture()
    tmpRect = _c_framework.Rect()
    _c_framework.rectInit(tmpRect, x/bmData.width,y/bmData.height,w/bmData.width, h/bmData.height)
    _c_framework.textureInit(tex, bmData, tmpRect)

    setmetatable(M, with {}
      .__index=(t,k)-> switch k
        when "width" tex.width
        when "height" tex.height)


    tmpMat = _c_framework.Matrix2!
    .draw=(m)->
      _c_framework.Matrix2_copy(tmpMat, m)
      _c_framework.Matrix2_append(tmpMat, tex.width, 0, 0, tex.height, 0, 0)
      _c_framework.quadDrawTex tex, tmpMat

fromFile: (path, errorOnInvalid=true)->
  path = framework.Texture.fixPath path
  imageData = _c_framework.loadImage(path)
  if not imageData
    if errorOnInvalid
      error("Invalid image file: "..path)
    return nil
  bmData = _c_framework.BitmapData()
  _c_framework.bitmapDataInit(bmData, imageData)
  _c_framework.rawBitmapDataCleanup(imageData)
  framework.Texture.new(bmData, 0, 0, bmData.width, bmData.height)

fixPath: (path) ->
  if not string.endsWith path, '.png'
    path = path..'.png'
  path
}
