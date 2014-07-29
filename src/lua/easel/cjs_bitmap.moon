

local Bitmap
Bitmap = {
new: (path) ->
  self = {}
  displayObj = framework.DisplayObject.new()
  setmetatable(self, {__newindex:displayObj, __index:displayObj})
  tex = framework.Texture.fromFile path
  self.draw = () ->
    x,y = self.getGlobalPos!
    r = self.getGlobalRot!
    tex.draw x+tex.width/2,y+tex.height/2, 0.5,0.5, -r

  return self

}

framework.cjs = {}
framework.cjs.Bitmap = Bitmap
