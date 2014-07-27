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
  @rotation = 0
  @x = 0
  @y = 0

  @isVisible = ->
    return not not (@visible and @alpha > 0 and @scaleX ~= 0 and @scaleY ~= 0)

  @getGlobalPos = ->
    if @parent ~= nil
      x,y = @parent.getGlobalPos!
      return x+@x, y+@y
    else
      return @x, @y
  
  @getGlobalRot = ->
    if @parent ~= nil
      r = @parent.getGlobalRot!
      return @rotation+r
    else
      return @rotation

  @setTransform = (x,y,scaleX, scaleY, rot) ->
    @x = x if x
    @y = y if y
    @rotation = rot if rot

}

framework.DisplayObject = DisplayObject
