NEXT_ID = 0
local DisplayObject
DisplayObject = {
new: ->
  self = {}
  self.id = NEXT_ID
  NEXT_ID += 1
  self.visible = true
  self.scaleX = 1
  self.scaleY = 1
  self.alpha = 1
  self.parent = nil
  self.tickEnabled = true
  self.rotation = 0
  self.x = 0
  self.y = 0
  self.skewX = 0
  self.regX = 0
  self.regY = 0
  self.skewY = 0
  self.isDisplayObj = true
  self.alpha = 1
  self._matrix = framework.Matrix2D.new!


-- Non-CJS additions

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



-- End Non-CJS additions



  self.isVisible = ->
    return not not (self.visible and self.alpha > 0 and self.scaleX ~= 0 and self.scaleY ~= 0)

  self.getMatrix = (matrix) ->
	o = self
    m = matrix and matrix.identity! or framework.Matrix2D.new!
	return m.appendTransform(o.x, o.y, o.scaleX, o.scaleY, o.rotation, o.skewX, o.skewY, o.regX, o.regY) -- .appendProperties(o.alpha, o.shadow, o.compositeOperation);


  self.localToGlobal = (x, y) ->
    mtx = self.getConcatenatedMatrix(self._matrix)
    return nil if not mtx
    mtx.append(1, 0, 0, 1, x, y)
    return mtx.tx, mtx.ty

  self.getConcatenatedMatrix = (matrix)->
    if (matrix)
      matrix.identity!
    else
      matrix = framework.Matrix2D.new!
    o = self
    while (o ~= nil)
      matrix.prependTransform(o.x, o.y, o.scaleX, o.scaleY, o.rotation, o.skewX, o.skewY, o.regX, o.regY) -- .prependProperties(o.alpha, o.shadow, o.compositeOperation, o.visible)
      o = o.parent
    return matrix

  self.setTransform = (x,y,scaleX, scaleY, rot, skewX, skewY, regX, regY) ->
    self.x = x and x or 0
    self.y = y and y or 0
    self.rotation = rot and rot or 0
    self.skewX = skewX and skewX or 0
    self.skewY = skewY and skewY or 0
    self.regX = regX and regX or 0
    self.regY = regY and regY or 0
    self.scaleX = scaleX and scaleX or 1
    self.scaleY = scaleY and scaleY or 1

  return self
}

framework.DisplayObject = DisplayObject
