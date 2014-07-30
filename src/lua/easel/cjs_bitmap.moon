

local Bitmap
Bitmap = {
new: (texLoader, path) ->
  self = {}
  displayObj = framework.DisplayObject.new()
  setmetatable(self, {__newindex:displayObj, __index:displayObj})
  tex = texLoader path
  self.draw = () ->
    x,y = self.getGlobalPos!
    r = self.getGlobalRot!
    tex.draw x+tex.width/2,y+tex.height/2, 0.5,0.5, -r

  return self

}

framework.cjs = {}
framework.cjs.Bitmap = Bitmap
