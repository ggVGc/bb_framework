framework = framework or {}

framework.Font = {
new: maker (imagePath, texLoadFunc) =>
  chars = 'abcdefghijklmnopqrstuvxyz1234567890,.'
  textures = {}

  string.gsub chars, '.', (c) ->
    textures[c] = texLoadFunc(imagePath..'/'..c)

  tmpMat = _c_framework.Matrix2!
  @drawString = (str, x=0, y=0, scale=1, reverse=false, tint) ->
    _c_framework.setTint tint[1]/255, tint[2]/255, tint[3]/255
    _c_framework.Matrix2_identity tmpMat
    w = 0
    if reverse
      str = str\reverse!
    string.gsub str, '.', (c) ->
      tex = textures[c]
      if c==' ' or not tex
        w += 20*(reverse and -1 or 1)
      else
        if reverse
          w-=tex.width*scale
        tmpMat.tx = x+w
        tmpMat.ty = y-tex.height*scale
        tmpMat.a = scale
        tmpMat.d = scale
        if not reverse
          w+=tex.width*scale
        tex.draw tmpMat
    _c_framework.setTint 1,1,1
          

}

framework.AssetLoader
