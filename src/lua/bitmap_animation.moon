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
    .draw = (x,y)->
      frames[curFrame].draw x, y
      curFrame = incWrap curFrame, #frames, 1
}

framework.BitmapAnimation
