

local Bitmap
Bitmap = {
new: maker (path)=>
  displayObj = framework.DisplayObject.new()
  setmetatable(@, {__newindex:displayObj, __index:displayObj})
  tex = framework.Texture.fromFile path
  
  cam = framework.Camera.createDefault 960
  @draw = ->
    cam.apply!
    x,y = @.getGlobalPos!
    tex.draw x,y

}

framework.cjs = {}
framework.cjs.Bitmap = Bitmap
