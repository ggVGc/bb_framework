

local Bitmap
Bitmap = {
new: (texLoader, path) ->
  self = {}
  displayObj = framework.DisplayObject.new()
  self.tex = texLoader path
  self.draw = () ->
    if not self.visible
      return
    Bitmap.drawCounter+=1
    _c_framework.DisplayObject_draw self.dispObj


  setmetatable(self, {__newindex:displayObj, __index:displayObj})
  _c_framework.DisplayObject_setTex(self.dispObj, self.tex.tex)
  return self
}
Bitmap.drawCounter = 0

framework.cjs = {}
framework.cjs.Bitmap = Bitmap
