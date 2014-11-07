local Button
Button = {
clickSfx: nil
new: maker (mc, initialDoStateSwitch)=>
  @getMc = -> mc
  w = mc.nominalBounds[3]
  h = mc.nominalBounds[4]
  if mc.stop
    mc.stop!
  
  playClickSfx = ->
    if Button.clickSfx and Button.clickSfx.play
      Button.clickSfx.play!

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

  isCursorOver = (cursorIndex, screenWidth, screenHeight)->
    cx = framework.Input.cursorX(cursorIndex)*screenWidth
    cy = (1-framework.Input.cursorY(cursorIndex))*screenHeight
    return @.isOver cx, cy
  
  curDownCursorIndex = nil
  @update = (screenWidth, screenHeight)->
    return false if not mc.visible
    if not curDownCursorIndex
      for i=1,framework.Input.MAX_CURSORS
        if framework.Input.cursorDown(i) and isCursorOver(i, screenWidth, screenHeight)
          curDownCursorIndex = i
          break

    over = curDownCursorIndex and isCursorOver(curDownCursorIndex, screenWidth, screenHeight)
    cursorIsDown = curDownCursorIndex and framework.Input.cursorDown(curDownCursorIndex)
    if not cursorIsDown
      curDownCursorIndex = nil
    if state == 0 and over and cursorIsDown
      if @doStateSwitch and mc.gotoAndStop
        mc.gotoAndStop stateOffset+1
      state = 1
      return false
    else if state == 1 and not cursorIsDown
      state = 0
      if @doStateSwitch and mc.gotoAndStop
        mc.gotoAndStop stateOffset
      playClickSfx!
      return true
    else if state ~= 0 and not over
      state = 0
      if @doStateSwitch and mc.gotoAndStop
        mc.gotoAndStop stateOffset
      return false
}

framework.cjs = framework.cjs or {}
framework.cjs.Button = Button
