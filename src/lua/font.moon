framework = framework or {}

framework.Font = {
new: maker (imagePath, texLoadFunc) =>
  chars = '!+-$abcdefghijklmnopqrstuvxyz1234567890,.'
  symTable = {
    '?': 'sym_q'
    '£': 'sym_gbp'
    '€': 'sym_euro'
  }
  textures = {}

  string.gsub chars, '.', (c) ->
    textures[c] = texLoadFunc(imagePath..'/'..c)
  for k,v in pairs symTable
    textures[v] = texLoadFunc(imagePath..'/'..v)

  tmpMat = _c_framework.Matrix2!
  reversing = false
  curWidth = 0
  curScale = 1
  pos = {}
  curAlpha = 1
  drawChar = (c) ->
    if symTable[c]
      c = symTable[c]
    else
      c = c\lower!
    tex = textures[c]
    if c==' ' or not tex
      curWidth += curScale*20*(reversing and -1 or 1)
    else
      if reversing
        curWidth-=math.ceil(tex.width*curScale)
      tmpMat.tx = math.floor(pos.x+curWidth)
      tmpMat.ty = math.floor(pos.y-tex.height*curScale)
      tmpMat.a = curScale
      tmpMat.d = curScale
      if not reversing
        curWidth+=math.ceil(tex.width*curScale)
      tex.draw tmpMat, curAlpha

  @drawString = (str, x=0, y=0, scale=1, reverse=false, tint, alpha) ->
    if tint
      if tint.r
        _c_framework.setTint tint.r/255, tint.g/255, tint.b/255
      else
        _c_framework.setTint tint[1]/255, tint[2]/255, tint[3]/255
    _c_framework.Matrix2_identity tmpMat
    reversing = reverse
    curScale = scale
    pos.x, pos.y = x, y
    if reversing
      str = str\reverse!
    curWidth = 0
    curAlpha = alpha or 1
    string.gsub str, "[%z\1-\127\194-\244][\128-\191]*", drawChar
    if tint
      _c_framework.setTint 1,1,1

}

framework.AssetLoader
