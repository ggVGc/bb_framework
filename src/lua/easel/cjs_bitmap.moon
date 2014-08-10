

local Bitmap
Bitmap = {
new: (texLoader, path) ->
  self = {}
  displayObj = framework.DisplayObject.new()
  setmetatable(self, {__newindex:displayObj, __index:displayObj})
  self.tex = texLoader path
  dispObjDraw = displayObj.draw
  self.draw = () ->
    dispObjDraw!
    Bitmap.drawCounter+=1
    self.tex.draw self._matrix

  return self
}
Bitmap.drawCounter = 0

framework.cjs = {}
framework.cjs.Bitmap = Bitmap
