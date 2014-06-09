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

    .draw=(x, y, pivotX, pivotY, rot, scaleX, scaleY)->
      w = scaleX or 1
      h = scaleY or 1
      _c_framework.quadDrawTex x or 0, y or 0,(scaleX or 1)*tex.width,
        (scaleY or 1)*tex.height,tex, rot or 0,pivotX or 0.5, pivotY or 0.5

fromFile: (path)->
  imageData = _c_framework.loadImage(path) or error("Invalid image file: "..path)
  bmData = _c_framework.BitmapData()
  _c_framework.bitmapDataInit(bmData, imageData)
  _c_framework.rawBitmapDataCleanup(imageData)
  framework.Texture.new(bmData, 0, 0, bmData.width, bmData.height)
}
