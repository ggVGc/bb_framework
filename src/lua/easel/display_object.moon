NEXT_ID = 0
local DisplayObject

DisplayObject ={


new: ->
  self = {}
  self.id = NEXT_ID
  NEXT_ID += 1
  self.visible = true
  self.alpha = 1
  self.tickEnabled = true
  self.isDisplayObj = true
  self.alpha = 1

  dispObj = _c_framework.DisplayObject()
  _c_framework.DisplayObject_init dispObj
  self.dispObj = dispObj


  --self.draw = ->
    --_c_framework.DisplayObject_getConcatenatedMatrix(dispObj, self._matrix)

  self.isVisible = ->
    --return not not (self.visible and self.alpha > 0 and self.scaleX ~= 0 and self.scaleY ~= 0)
    return not not (self.visible and self.alpha > 0)

  cMat = _c_framework.Matrix2!
  self.localToGlobal = (x, y) ->
    _c_framework.Matrix2_identity(cMat)
    _c_framework.DisplayObject_getConcatenatedMatrix(dispObj, cMat)
    _c_framework.Matrix2_append(cMat, 1, 0, 0, 1, x, y)
    return cMat.tx, cMat.ty

  self.setTransform = (x=0,y=0,scaleX=1, scaleY=1, rot=0, skewX=0, skewY=0, regX=0, regY=0) ->
    _c_framework.DisplayObject_setTransform(dispObj, x, y, scaleX, scaleY, rot, skewX, skewY, regX, regY)

  mt = {
  __index: (obj, key) ->
    switch key
      when 'x'
        --print 'x'
        return dispObj.x
      when 'y'
        --print 'y'
        return dispObj.y
      when 'regX'
        --print 'regX'
        return dispObj.regX
      when 'regY'
        --print 'regY'
        return dispObj.regY
      when 'scaleX'
        --print 'scaleX'
        return dispObj.scaleX
      when 'scaleY'
        --print 'scaleY'
        return dispObj.scaleY
      when 'skewX'
        --print 'skewX'
        return dispObj.skewX
      when 'skewY'
        --print 'skewY'
        return dispObj.skewY
      when 'rotation'
        --print 'rotation'
        return dispObj.rotation
      else
        return rawget(obj, key)

  __newindex: (obj, key, val) ->
    switch key
      when 'x'
        dispObj.x = val
      when 'y'
        dispObj.y = val
      when 'regX'
        dispObj.regX = val
      when 'regY'
        dispObj.regY = val
      when 'skewX'
        dispObj.skewX = val
      when 'skewY'
        dispObj.skewY= val
      when 'scaleX'
        dispObj.scaleX = val
      when 'scaleY'
        dispObj.scaleY= val
      when 'rotation'
        dispObj.rotation = val
      else
        rawset(obj, key, val)
  }


  setmetatable(self, mt)
  return self
}

framework.DisplayObject = DisplayObject
