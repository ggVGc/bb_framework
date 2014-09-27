local Button
Button = {
new: maker (mc)=>
  w = mc.nominalBounds[3]
  h = mc.nominalBounds[4]
  if mc.stop
    mc.stop!


  state = 0

  @isOver = (x,y) ->
    globPos = mc.localToGlobal(0,0)
    return x > globPos.x and x<globPos.x+w and y>globPos.y and y<globPos.y+h

  @isPressOver = (screenWidth, screenHeight) ->
    cx = framework.Input.cursorX()*screenWidth
    cy = (1-framework.Input.cursorY())*screenHeight
    over = @.isOver cx, cy
    return over and framework.Input.cursorDown!


  @update = (screenWidth, screenHeight)->
    return false if not mc.visible
    cx = framework.Input.cursorX()*screenWidth
    cy = (1-framework.Input.cursorY())*screenHeight
    over = @.isOver cx, cy
    if state == 0 and over and framework.Input.cursorDown!
      if mc.gotoAndStop
        mc.gotoAndStop 1
      state = 1
      return false
    else if state == 1 and not framework.Input.cursorDown!
      state = 0
      if mc.gotoAndStop
        mc.gotoAndStop 0
      return true
    else if state ~= 0 and not over
      state = 0
      if mc.gotoAndStop
        mc.gotoAndStop 0
      return false
}

framework.cjs = framework.cjs or {}
framework.cjs.Button = Button
