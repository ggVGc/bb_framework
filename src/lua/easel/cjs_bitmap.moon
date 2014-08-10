

local Bitmap
Bitmap = {
new: (texLoader, path) ->
  self = {}
  displayObj = framework.DisplayObject.new()
  setmetatable(self, {__newindex:displayObj, __index:displayObj})
  self.tex = texLoader path
  cacheMat = framework.Matrix2D.new!
  self.draw = () ->
    Bitmap.drawCounter+=1
    cacheMat.copy self._matrix
    self.tex.draw cacheMat

  return self
}
Bitmap.drawCounter = 0

framework.cjs = {}
framework.cjs.Bitmap = Bitmap
