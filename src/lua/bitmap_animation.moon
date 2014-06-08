framework = framework or {}

incWrap=(index, len, start=0)->
  if index>=len
    start
  else
    index+1

framework.BitmapAnimation = {
new:(frames)->
  curFrame = 1
  with {}
    .draw = ->
      frames[curFrame].draw!
      --curFrame = incWrap curFrame, #frames, 1
      print curFrame
}

framework.BitmapAnimation
