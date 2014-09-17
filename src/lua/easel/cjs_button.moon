local Button
Button = {
new: maker (mc)=>
  w = mc.nominalBounds[3]
  h = mc.nominalBounds[4]
  mc.stop!

  globPos = mc.localToGlobal(0,0)

  state = 0

  @update = (inp, screenWidth, screenHeight)->
    cx = framework.Input.cursorX()*screenWidth
    cy = (1-framework.Input.cursorY())*screenHeight
    over = cx > globPos.x and cx<globPos.x+w and cy>globPos.y and cy<globPos.y+h
    if state == 0 and over and framework.Input.cursorDown!
      mc.gotoAndStop 1
      state = 1
      return false
    else if state == 1 and inp.cursorReleased!
      state = 0
      mc.gotoAndStop 0
      return true
    else if state ~= 0 and not over
      state = 0
      mc.gotoAndStop 0
      return false
}

framework.cjs = framework.cjs or {}
framework.cjs.Button = Button
