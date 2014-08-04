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

  self.isVisible = ->
    return not not (self.visible and self.alpha > 0 and self.scaleX ~= 0 and self.scaleY ~= 0)

  self.getMatrix = (matrix) ->
	o = self
    m = matrix and matrix.identity! or framework.Matrix2D.new!
	return m.appendTransform(o.x, o.y, o.scaleX, o.scaleY, o.rotation, o.skewX, o.skewY, o.regX, o.regY) -- .appendProperties(o.alpha, o.shadow, o.compositeOperation);


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

  self.getGlobalPos = ->
    if self.parent ~= nil
      x,y = self.parent.getGlobalPos!
      return x+self.x-self.regX, y+self.y-self.regY
    else
      return self.x-self.regX, self.y-self.regY
    
  
  self.getGlobalRot = ->
    if self.parent ~= nil
      r = self.parent.getGlobalRot!
      return self.rotation+r
    else
      return self.rotation

  self.getGlobalScale = ->
    if self.parent ~= nil
      sx, sy = self.parent.getGlobalScale!
      return self.scaleX*sx, self.scaleY*sy
    else
      return self.scaleX, self.scaleY


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
