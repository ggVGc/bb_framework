--framework = framework or {}

--incWrap=(index, len, start=0)->
  --if index>=len
    --start
  --else
    --index+1

--framework.BitmapAnimation = {
--new: maker (frames, frameTimes={1}) =>
  --if not _.isArray frameTimes
    --frameTimes = {frameTimes}

  --local curFrame
  --tween = with Tween.get({},{loop:true})
    --.call -> curFrame=1
    --lastW = 0
    --for i=1,#frames
      --t = frameTimes[i] or lastW
      --lastW = t
      --.wait(t*1000).call -> curFrame+=1 if curFrame!=#frames

    --.tick 0

  --@update = (deltaMs) ->
    --tween.tick deltaMs, false

  --@draw = (x,y)->
    --frames[curFrame].draw x, y
--}

--framework.BitmapAnimation
