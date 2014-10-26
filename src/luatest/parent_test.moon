
export Main = { new:maker =>
  levelLib = dofile 'flash/level/level.lua'
  levelLib.sourceFolder = 'flash/level'
  par = levelLib.powerup_fast.new!
  par._tick!
  print 'par', par.timeline, par.btn, par.btn.parent.timeline
  @update = ->
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
