framework = framework or {}

incWrap=(index, len, start=0)->
  if index>=len
    start
  else
    index+1

framework.BitmapAnimation = {
new: maker (frames, timePerFrame=1) =>
  timePerFrame*=1000
  curFrame = 1
  curFrameTime = 0
  @update = (deltaMs) ->
    curFrameTime = curFrameTime+deltaMs
    if curFrameTime>=timePerFrame
      curFrame = incWrap curFrame, #frames, 1
      curFrameTime = 0
  @draw = (x,y)->
    frames[curFrame].draw x, y
}

framework.BitmapAnimation
