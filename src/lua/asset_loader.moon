framework = framework or {}

framework.AssetLoader = {
new: maker (initialTexSheets) =>
  print 'Async asset loader:', _c_framework.AsyncAssetLoader
  @texSheets = initialTexSheets

  queueIn=helper.newqueue()
  queueOut=helper.newqueue()
  @_thread = helper.newthread queueIn, queueOut
  tasks = {}

  @getTexture = (path, errorOnInvalid) ->
    t = framework.AssetLoader.tryGetTexFromSheets(path, @texSheets)
    if not t
      --print path
      t = framework.Texture.fromFile(path, errorOnInvalid)
    return t

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

  @update = ->
    t = queueOut\peek!
    if t
      a = helper.update t
      o = tasks[t]
      o.asset = framework.StreamingAudio.new a
      tasks[t] = nil
      queueOut\remove t

  @loadAudio = (path)->
    a = {
      asset: nil
      type: 'audio'
    }
    t = _c_framework.AsyncAssetLoader.loadAudio path
    tasks[t] = a
    queueIn\addtask t
    return a




tryGetTexFromSheets: (path, sheets)->
  for s in *sheets
    if s.exists path
      return s.createTexture path
}

framework.AssetLoader
