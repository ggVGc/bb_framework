local DisplayObject



mt = {
__index: (obj, key) ->
  obj.dispObj[key] or rawget(obj, key)

__newindex: (obj, key, val) ->
  switch key
    when 'x'
      obj.dispObj.x = val
    when 'y'
      obj.dispObj.y = val
    when 'regX'
      obj.dispObj.regX = val
    when 'regY'
      obj.dispObj.regY = val
    when 'skewX'
      obj.dispObj.skewX = val
    when 'skewY'
      obj.dispObj.skewY= val
    when 'scaleX'
      obj.dispObj.scaleX = val
    when 'scaleY'
      obj.dispObj.scaleY= val
    when 'rotation'
      obj.dispObj.rotation = val
    when 'alpha'
      obj.dispObj.alpha= val
    else
      rawset(obj, key, val)
}




eventMT = {
  handlers:{}
  __index: (obj, k) ->
    return (...) ->
      if obj.handlers[k]
        for f in *obj.handlers[k]
          f(obj.self, ...)
      if obj.self.parent
        obj.self.parent.event[k](...)
  __newindex: (obj, eventName, func) ->
    if not obj.handlers[eventName]
      obj.handlers[eventName] = {}
    table.insert obj.handlers[eventName], func
}


DisplayObject = {
NEXT_ID: 0
new: ->
  self = {}
  self.id = DisplayObject.NEXT_ID
  DisplayObject.NEXT_ID += 1
  self.visible = true
  self.tickEnabled = true
  self.isDisplayObj = true
  self.parent = nil

  self.event = {self:self, handlers:{}}
  setmetatable self.event, eventMT

  dispObj = _c_framework.DisplayObject()
  _c_framework.DisplayObject_init dispObj
  self.dispObj = dispObj

  self.isVisible = ->
    not not self.visible

  self.setTransform = (x=0,y=0,scaleX=1, scaleY=1, rot=0, skewX=0, skewY=0, regX=0, regY=0) ->
    _c_framework.DisplayObject_setTransform(dispObj, x, y, scaleX, scaleY, rot, skewX, skewY, regX, regY)


  cMat = _c_framework.Matrix2!
  self.localToGlobal = (x, y)->
    _c_framework.Matrix2_identity(cMat)
    _c_framework.DisplayObject_getConcatenatedMatrix(dispObj, cMat)
    _c_framework.Matrix2_append(cMat, @scaleX, 0, 0, @scaleY, x, y)
    return cMat.tx, cMat.ty
  

  self.globalToLocal = (x, y)->
    _c_framework.Matrix2_identity(cMat)
    _c_framework.DisplayObject_getConcatenatedMatrix(dispObj, cMat)
    _c_framework.Matrix2_invert(cMat)
    _c_framework.Matrix2_append(cMat, @scaleX, 0, 0, @scaleY, x, y)
    return cMat.tx, cMat.ty

  self.localToLocal = (x, y, target)->
    pt = self.localToGlobal(x, y)
    return target.globalToLocal(pt.x, pt.y)

  self.regToGlobal = ->
    self.localToGlobal @regX, @regY

  setmetatable(self, mt)
  return self
}

framework.DisplayObject = DisplayObject
