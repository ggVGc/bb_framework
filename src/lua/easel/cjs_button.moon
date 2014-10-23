local Button
Button = {
new: maker (mc, initialDoStateSwitch)=>
  @getMc = -> mc
  w = mc.nominalBounds[3]
  h = mc.nominalBounds[4]
  if mc.stop
    mc.stop!
  
  @doStateSwitch = initialDoStateSwitch==nil and true or initialDoStateSwitch

  state = 0
  stateOffset = 0
  @setStateOffset = (offset)->
    stateOffset = offset
    mc.gotoAndStop(stateOffset+state)

  @isOver = (x,y) ->
    return false if not mc.visible
    globX, globY = mc.localToGlobal(0,0)
    return x > globX and x<globX+w and y>globY and y<globY+h

  @isPressOver = (screenWidth, screenHeight) ->
    return false if not mc.visible
    cx = framework.Input.cursorX()*screenWidth
    cy = (1-framework.Input.cursorY())*screenHeight
    over = @.isOver cx, cy
    return over and framework.Input.cursorDown!


  @update = (screenWidth, screenHeight)->
    return false if not mc.visible
    downCursorIndex = framework.Input.anyCursorDown!
    local cx, cy
    if downCursorIndex
      cx = framework.Input.cursorX(downCursorIndex)*screenWidth
      cy = (1-framework.Input.cursorY(downCursorIndex))*screenHeight
    over = downCursorIndex and @.isOver cx, cy
    if state == 0 and over and downCursorIndex
      if @doStateSwitch and mc.gotoAndStop
        mc.gotoAndStop stateOffset+1
      state = 1
      return false
    else if state == 1 and not downCursorIndex
      state = 0
      if @doStateSwitch and mc.gotoAndStop
        mc.gotoAndStop stateOffset
      return true
    else if state ~= 0 and not over
      state = 0
      if @doStateSwitch and mc.gotoAndStop
        mc.gotoAndStop stateOffset
      return false
}

framework.cjs = framework.cjs or {}
framework.cjs.Button = Button
