NEXT_ID = 0
local DisplayObject

DisplayObject

DisplayObject = {
mt: {
__index: (obj, key) ->
  switch key
    when 'x'
      return rawget(obj, 'dispObj').x
    when 'y'
      return rawget(obj, 'dispObj').y
    when 'regX'
      return rawget(obj, 'dispObj').regX
    when 'regY'
      return rawget(obj, 'dispObj').regY
    when 'scaleX'
      return rawget(obj, 'dispObj').scaleX
    when 'scaleY'
      return rawget(obj, 'dispObj').scaleY
    when 'skewX'
      return rawget(obj, 'dispObj').skewX
    when 'skewY'
      return rawget(obj, 'dispObj').skewY
    when 'rotation'
      return rawget(obj, 'dispObj').rotation
    when 'parent'
      return rawget(obj, '__parent')
    else
      return rawget(obj, key)

__newindex: (obj, key, val) ->
  switch key
    when 'x'
      rawget(obj, 'dispObj').x = val
    when 'y'
      rawget(obj, 'dispObj').y = val
    when 'regX'
      rawget(obj, 'dispObj').regX = val
    when 'regY'
      rawget(obj, 'dispObj').regY = val
    when 'skewX'
      rawget(obj, 'dispObj').skewX = val
    when 'skewY'
      rawget(obj, 'dispObj').skewY= val
    when 'rotation'
      rawget(obj, 'dispObj').rotation = val
    when 'parent'
      rawget(obj, 'dispObj').parent = val and val.dispObj or nil
      rawset(obj, '__parent', val)
    else
      rawset(obj, key, val)
}

new: ->
  self = {}
  self.id = NEXT_ID
  NEXT_ID += 1
  self.visible = true
  self.alpha = 1
  self.tickEnabled = true
  self.isDisplayObj = true
  self.alpha = 1
  self._matrix = _c_framework.Matrix2!

  dispObj = _c_framework.DisplayObject()
  _c_framework.DisplayObject_init dispObj
  self.dispObj = dispObj

  self.event = {handlers:{}}
  eventMT = {
    handlers:{}
    __index: (obj, k) ->
      return (...) ->
        if obj.handlers[k]
          for f in *obj.handlers[k]
            f(...)
        if self.parent
          self.parent.event[k](...)
    __newindex: (obj, eventName, func) ->
      if not obj.handlers[eventName]
        obj.handlers[eventName] = {}
      table.insert obj.handlers[eventName], func
  }

  
  setmetatable self.event, eventMT

  self.draw = ->
    _c_framework.DisplayObject_getConcatenatedMatrix(dispObj, self._matrix)

  self.isVisible = ->
    --return not not (self.visible and self.alpha > 0 and self.scaleX ~= 0 and self.scaleY ~= 0)
    return not not (self.visible and self.alpha > 0)

  cMat = _c_framework.Matrix2!
  self.localToGlobal = (x, y) ->
    _c_framework.Matrix2_identity(cMat)
    _c_framework.DisplayObject_getConcatenatedMatrix(dispObj, cMat)
    _c_framework.Matrix2_append(cMat, 1, 0, 0, 1, x, y)
    return cMat.tx, cMat.ty

  self.getConcatenatedMatrix = (matrix)->
    _c_framework.DisplayObject_getConcatenatedMatrix(dispObj, cMat)
    matrix.a = cMat.a
    matrix.b = cMat.b
    matrix.c = cMat.c
    matrix.d = cMat.d
    matrix.tx = cMat.tx
    matrix.ty = cMat.ty

  self.setTransform = (x=0,y=0,scaleX=1, scaleY=1, rot=0, skewX=0, skewY=0, regX=0, regY=0) ->
    _c_framework.DisplayObject_setTransform(dispObj, x, y, scaleX, scaleY, rot, skewX, skewY, regX, regY)


  setmetatable(self, DisplayObject.mt)
  return self
}

framework.DisplayObject = DisplayObject
