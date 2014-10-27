

local Bitmap
Bitmap = {
new: (texLoader, path) ->
  displayObj = framework.DisplayObject.new()
  self = displayObj
  self.tex = texLoader path
  self.draw = () ->
    if not self.visible
      return
    Bitmap.drawCounter+=1
    _c_framework.DisplayObject_draw self.dispObj

  _c_framework.DisplayObject_setTex(self.dispObj, self.tex.tex)
  return self
}
Bitmap.drawCounter = 0

framework.cjs = {}
framework.cjs.Bitmap = Bitmap
