
export Main = { new:maker =>
  @al = framework.AssetLoader.new!
  @mainMusicAsset = @al.loadAudio 'dos.ogg'
  @update = ->
    if @mainMusicAsset.loaded and not @mainMusicAsset.asset.isPlaying!
      @mainMusicAsset.asset.play!
    @al.update!
  @draw = ->
}





--export Main = { new:maker =>
  --x = nil
  --@update = ->
    --if not x
      --@queueIn=helper.newqueue()
      --@queueOut=helper.newqueue()
      --@th=helper.newthread(@queueIn, @queueOut)
      ----print("thread:", th)

      
      --@t = _c_framework.AsyncAssetLoader.loadAudio 'dos.ogg'
      --print 'task', @t
      --@queueIn\addtask @t
      --print 'asd'
      --while true
        --print 'asd'
        --tx = @queueOut\wait 1
        --if tx
          --print tx
          --a = helper.update tx
          --_c_framework.audioPlay a
          --print 'aaa', a
      --x = 1
      --c = nil
      --print @t, 'state:', helper.state @t
      --tt = @queueOut\peek!
      --if tt
        --helper.update @t
        --print tt
    --else
      --x = 1

  --@draw = ->
--}
