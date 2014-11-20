local Button
Button = {
clickSfx: nil
new: maker (mc, initialDoStateSwitch, initialTriggerOnDown, hitMc)=>
  @getMc = -> mc
  hitMc = hitMc or mc
  w = hitMc.nominalBounds[3]
  h = hitMc.nominalBounds[4]
  if mc.stop
    mc.stop!
  
  playClickSfx = ->
    if Button.clickSfx and Button.clickSfx.play
      Button.clickSfx.play!

  @doStateSwitch = initialDoStateSwitch==nil and true or initialDoStateSwitch
  @triggerOnDown = initialTriggerOnDown

  state = 0
  stateOffset = 0
  @setStateOffset = (offset)->
    stateOffset = offset
    mc.gotoAndStop(stateOffset+state)

  @isOver = (x,y) ->
    return false if not mc.visible
    globX, globY = hitMc.localToGlobal(0,0)
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
  
  @update = (inp, screenWidth, screenHeight)->
    return false, false if not mc.visible

    if state == 1
      ind = inp.anyCursorReleased!
      if ind and isCursorOver(ind, screenWidth, screenHeight)
        state = 0
        if @doStateSwitch and mc.gotoAndStop
          mc.gotoAndStop stateOffset
        playClickSfx!
        return not @triggerOnDown

    local cursorOver, clicked
    for i=1,framework.Input.cursorCount!
      if framework.Input.cursorDown(i) and isCursorOver(i, screenWidth, screenHeight)
        cursorOver = i
        break
    if state == 0 and cursorOver
      if @doStateSwitch and mc.gotoAndStop
        mc.gotoAndStop stateOffset+1
      state = 1
      return @triggerOnDown

    if state ~= 0 and not cursorOver
      state = 0
      if @doStateSwitch and mc.gotoAndStop
        mc.gotoAndStop stateOffset
      return  false

    --return clicked, cursorOver
    return clicked
}

framework.cjs = framework.cjs or {}
framework.cjs.Button = Button
