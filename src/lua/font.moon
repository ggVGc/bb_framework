framework = framework or {}

framework.Font = {
new: maker (imagePath, texLoadFunc) =>
  chars = 'abcdefghijklmnopqrstuvxyz1234567890,.'
  textures = {}

  string.gsub chars, '.', (c) ->
    textures[c] = texLoadFunc(imagePath..'/'..c)

  tmpMat = _c_framework.Matrix2!

  reversing = false

  curWidth = 0
  curScale = 1
  pos = {}
  curAlpha = 1
  drawChar = (c) ->
    tex = textures[c]
    if c==' ' or not tex
      curWidth += 20*(reversing and -1 or 1)
    else
      if reversing
        curWidth-=tex.width*curScale
      tmpMat.tx = pos.x+curWidth
      tmpMat.ty = pos.y-tex.height*curScale
      tmpMat.a = curScale
      tmpMat.d = curScale
      if not reversing
        curWidth+=tex.width*curScale
      tex.draw tmpMat, curAlpha


  @drawString = (str, x=0, y=0, scale=1, reverse=false, tint, alpha) ->
    if tint
      _c_framework.setTint tint[1]/255, tint[2]/255, tint[3]/255
    _c_framework.Matrix2_identity tmpMat
    reversing = reverse
    curScale = scale
    pos.x, pos.y = x, y
    if reversing
      str = str\reverse!
    curWidth = 0
    curAlpha = alpha or 1
    string.gsub str, '.', drawChar
    if tint
      _c_framework.setTint 1,1,1

}

framework.AssetLoader
