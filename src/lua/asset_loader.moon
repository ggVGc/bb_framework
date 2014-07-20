framework = framework or {}

framework.AssetLoader = {
new: maker (texSheets) =>

  @getTexture = (path, errorOnInvalid) ->
    framework.AssetLoader.tryGetTexFromSheets(path, texSheets) or framework.Texture.fromFile(path, errorOnInvalid)

  @getAnimationFrames = (path) ->
    frame1 = framework.Texture.fromFile path..'/1', false
    if frame1
      return for index in fun.duplicate!
        tex = framework.Texture.fromFile path..'/'..tostring(index), false
        if not tex
          break
        tex
    nil

  @getAnimation = (path, ...)->
    frames = @.getAnimationFrames path
    if frames
      return framework.BitmapAnimation.new frames, ...


tryGetTexFromSheets: (path, sheets)->
  for s in *sheets
    if s.exists path
      return s.createTexture path
}

framework.AssetLoader
