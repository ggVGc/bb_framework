
export Main = { new:maker =>
  assLoad = framework.AssetLoader.new {
  }

  images = {
    assLoad.getTexture 'data/gfx/pre_loading.png'
    assLoad.getTexture 'data/gfx/sheets/loading_start.png'
    assLoad.getTexture 'data/gfx/sheets/game.png'
  }
  @update = ->
  @draw = ->
    for i in *images
      print i
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
