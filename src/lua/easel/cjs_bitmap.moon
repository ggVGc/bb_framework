

local Bitmap
Bitmap = {
new: maker (path)=>
  displayObj = framework.DisplayObject.new()
  setmetatable(@, {__newindex:displayObj, __index:displayObj})
  tex = framework.Texture.fromFile path
  @draw = (sceneHeight) ->
    x,y = @.getGlobalPos!
    r = @.getGlobalRot!
    tex.draw x,sceneHeight-y, nil,nil, -r

}

framework.cjs = {}
framework.cjs.Bitmap = Bitmap
