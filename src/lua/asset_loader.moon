framework = framework or {}


local AL
AL = {
AssetType:{
  Audio: 'audio'
  TexSheet: 'texture_sheet'
},
new: maker (initialTexSheets) =>
  @texSheets = initialTexSheets

  queueIn=helper.newqueue()
  queueOut=helper.newqueue()
  @_thread = helper.newthread queueIn, queueOut
  taskCount = 0
  tasks = {}

  @allLoaded = ->
    return taskCount == 0

  @getTexture = (path, errorOnInvalid) ->
    t = framework.AssetLoader.tryGetTexFromSheets(path, @texSheets)
    if not t
      --print path
      t = framework.Texture.fromFile(path, errorOnInvalid)
    return t

  --@getAnimationFrames = (path) ->
    --frame1 = framework.Texture.fromFile path..'/1', false
    --if frame1
      --return for index in fun.duplicate!
        --tex = framework.Texture.fromFile path..'/'..tostring(index), false
        --if not tex
          --break
        --tex
    --nil

  --@getAnimation = (path, ...)->
    --frames = @.getAnimationFrames path
    --if frames
      --return framework.BitmapAnimation.new frames, ...

  @update = ->
    t = queueOut\peek!
    if t
      loadedData = helper.update t
      o = tasks[t]
      tasks[t] = nil
      print 'AssetLoader, loaded:', o.a.path
      switch o.a.type
        when AL.AssetType.Audio
          o.a.asset = framework.Audio.new loadedData
          o.a.asset.setGroup o.a.group
          setmetatable o.a, {__index:o.a.asset, __newindex:o.a.asset}
        when AL.AssetType.TexSheet
          rectMap = framework.TextureSheet.parseRectMap o.rectMapText, loadedData.height
          bmData = _c_framework.BitmapData()
          _c_framework.bitmapDataInit(bmData, loadedData)
          _c_framework.rawBitmapDataCleanup(loadedData)
          framework.Texture.bmDataCache[o.path] = bmData
          o.a.asset = framework.TextureSheet.new rectMap, bmData
          o.a.asset.path = o.path
          table.insert @texSheets, o.a.asset

      queueOut\remove t
      taskCount-=1

  @releaseSheet = (path)->
    for i=1,#@texSheets
      s = @texSheets[i]
      print i, s.path, path
      if s.path == path
        table.remove @texSheets, i
        framework.Texture.bmDataCache[path] = nil
        return
    print 'WARNING!', 'Tried freeing invalid tex sheet: '..path

  @loadTexSheet = (baseName)->
    a = {
      asset: nil
      type: AL.AssetType.TexSheet
      path: baseName..'.png'
    }
    data = {
      a:a
      rectMapText: _c_framework.loadText(baseName..'.txt')
      path: baseName..'.png'
    }
    t = _c_framework.AsyncAssetLoader.loadImage(data.path)
    tasks[t] = data
    queueIn\addtask t
    taskCount+=1
    return a

  @loadAudio = (path, loop, groupName)->
    a = {
      asset: nil
      type: AL.AssetType.Audio
      group:groupName
      path:path
    }
    t = _c_framework.AsyncAssetLoader.loadAudio path, (loop and true or false)
    tasks[t] = {a:a}
    queueIn\addtask t
    taskCount+=1
    return a




tryGetTexFromSheets: (path, sheets)->
  for s in *sheets
    if s.exists path
      return s.createTexture path
}

framework.AssetLoader = AL
return AL
