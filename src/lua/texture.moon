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


    tmpMat = framework.Matrix2D.new!
    scaleMat = framework.Matrix2D.new!
    .draw=(m)->

      --if type(x) == 'table'
      tmpMat.a = m.a
      tmpMat.b = m.b
      tmpMat.c = m.c
      tmpMat.d = m.d
      tmpMat.tx = m.tx
      tmpMat.ty = m.ty
      --else
        --px = pivotX or 0.5
        --py = pivotY or 0.5
        --sx = scaleX or 1
        --sy = scaleY or 1
        --w = sx*tex.width
        --h = sy*tex.height
        --tmpMat.identity!
        --tmpMat.translate -w*px, -h*py
        --tmpMat.rotate (rot and rot/360 or 0)
        --tmpMat.translate w*px, h*py
        --tmpMat.translate x-w*px, y-h*py
        --scaleMat.a = sx
        --scaleMat.d = sy
        --tmpMat.append(scaleMat.a, scaleMat.b, scaleMat.c, scaleMat.d, scaleMat.tx, scaleMat.ty)

      scaleMat.a = tex.width
      scaleMat.d = tex.height
      tmpMat.append(scaleMat.a, scaleMat.b, scaleMat.c, scaleMat.d, scaleMat.tx, scaleMat.ty)
      _c_framework.quadDrawTex tmpMat.a, tmpMat.b, tmpMat.c, tmpMat.d, tmpMat.tx, tmpMat.ty, tex

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
