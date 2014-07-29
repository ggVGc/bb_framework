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

  self.isVisible = ->
    return not not (self.visible and self.alpha > 0 and self.scaleX ~= 0 and self.scaleY ~= 0)

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

  self.setTransform = (x,y,scaleX, scaleY, rot, skewX, skewY, regX, regY) ->
    self.x = x if x
    self.y = y if y
    self.rotation = rot if rot
    self.skewX = skewX if skewX
    self.skewY = skewY if skewY
    self.regX = regX if regX
    self.regY = regY if regY

  return self
}

framework.DisplayObject = DisplayObject
