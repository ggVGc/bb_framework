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

}

framework.DisplayObject = DisplayObject
