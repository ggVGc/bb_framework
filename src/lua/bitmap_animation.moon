framework = framework or {}

incWrap=(index, len, start=0)->
  if index>=len
    start
  else
    index+1

framework.BitmapAnimation = {
new: maker (frames, frameTimes={1}) =>
  if not _.isArray frameTimes
    frameTimes = {frameTimes}
  curFrame = 1
  frameTimeCounter = 0
  @update = (deltaMs) ->
    frameTimeCounter += deltaMs
    curFrameTime = do
      if curFrame <= #frameTimes
        frameTimes[curFrame]
      else
        frameTimes[#frameTimes]

    if frameTimeCounter>= curFrameTime*1000
      curFrame = incWrap curFrame, #frames, 1
      frameTimeCounter = 0
  @draw = (x,y)->
    frames[curFrame].draw x, y
}

framework.BitmapAnimation
