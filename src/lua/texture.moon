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


    cacheMat = framework.Matrix2D.new!
    scaleMat = framework.Matrix2D.new!
    .draw=(x, y, pivotX, pivotY, rot, scaleX, scaleY)->

      if type(x) == 'table'
        cacheMat.copy(x)
      else
        px = pivotX or 0.5
        py = pivotY or 0.5
        sx = scaleX or 1
        sy = scaleY or 1
        w = sx*tex.width
        h = sy*tex.height
        cacheMat.identity!
        cacheMat.translate -w*px, -h*py
        cacheMat.rotate (rot and rot/360 or 0)
        cacheMat.translate w*px, h*py
        cacheMat.translate x-w*px, y-h*py
        scaleMat.identity!
        cacheMat.appendMatrix(scaleMat.scale(sx, sy))

      scaleMat.identity!
      cacheMat.appendMatrix(scaleMat.scale(tex.width, tex.height))
      _c_framework.quadDrawTex cacheMat.a, cacheMat.b, cacheMat.c, cacheMat.d, cacheMat.tx, cacheMat.ty, tex

      --_c_framework.quadDrawTex x or 0, y,(scaleX or 1)*tex.width,
        --(scaleY or 1)*tex.height,tex, rot or 0,pivotX or 0.5, pivotY or 0.5

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
