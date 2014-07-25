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
  @x = 0
  @y = 0

  @isVisible = ->
    return not not (@visible and @alpha > 0 and @scaleX ~= 0 and @scaleY ~= 0)

}

framework.DisplayObject = DisplayObject
