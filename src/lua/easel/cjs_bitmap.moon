

local Bitmap
Bitmap = {
new: maker (path)=>
  displayObj = framework.DisplayObject.new()
  setmetatable(@, {__newindex:displayObj, __index:displayObj})
  tex = framework.Texture.fromFile path
  @draw = () ->
    x,y = @.getGlobalPos!
    r = @.getGlobalRot!
    tex.draw x+tex.width/2,y+tex.height/2, 0.5,0.5, -r

}

framework.cjs = {}
framework.cjs.Bitmap = Bitmap
