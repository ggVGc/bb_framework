framework = framework or {}

framework.Font = {
new: maker (imagePath, texLoadFunc) =>
  --chars = 'abcdefghijklmnopqrstuvxyz1234567890'
  chars = '1234567890'
  textures = {}

  string.gsub chars, '.', (c) ->
    textures[c] = texLoadFunc(imagePath..'/'..c)

  tmpMat = _c_framework.Matrix2!
  @drawString = (str, x, y, reverse) ->
    _c_framework.Matrix2_identity tmpMat
    w = 0
    if reverse
      str = str\reverse!
    string.gsub str, '.', (c) ->
      if reverse
        w-=textures[c].width
      tmpMat.tx = x+w
      tmpMat.ty = y
      if not reverse
        w+=textures[c].width
      textures[c].draw tmpMat
        

}

framework.AssetLoader
