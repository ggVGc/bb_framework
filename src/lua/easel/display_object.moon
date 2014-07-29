NEXT_ID = 0
local DisplayObject
DisplayObject = {
new: maker ()=>
  @id = NEXT_ID
  NEXT_ID += 1
  @visible = true
  @scaleX = 1
  @scaleY = 1
  @alpha = 1
  @parent = nil
  @tickEnabled = true
  @rotation = 0
  @x = 0
  @y = 0
  @skewX = 0
  @regX = 0
  @regY = 0
  @skewY = 0
  @isDisplayObj = true
  @alpha = 1

  @isVisible = ->
    return not not (@visible and @alpha > 0 and @scaleX ~= 0 and @scaleY ~= 0)

  @getGlobalPos = ->
    if @parent ~= nil
      x,y = @parent.getGlobalPos!
      return x+@x-@regX, y+@y-@regY
    else
      return @x-@regX, @y-@regY
    
  
  @getGlobalRot = ->
    if @parent ~= nil
      r = @parent.getGlobalRot!
      return @rotation+r
    else
      return @rotation

  @setTransform = (x,y,scaleX, scaleY, rot, skewX, skewY, regX, regY) ->
    @x = x if x
    @y = y if y
    @rotation = rot if rot
    @skewX = skewX if skewX
    @skewY = skewY if skewY
    @regX = regX if regX
    @regY = regY if regY
}

framework.DisplayObject = DisplayObject
