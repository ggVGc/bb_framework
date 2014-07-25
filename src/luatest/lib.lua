local lib = {}

lib.cloud_1= {}
lib.cloud_1.new = function()
  --return framework.Bitmap.new(img.cloud_1)
  local this = framework.DisplayObject.new()
    this.draw= function()
    end
    this.isVisible = function() return true end
  return this
end

lib.cloud = {}
lib.cloud.new = function()
  local this = framework.Container.new()
  this.instance = lib.cloud_1.new()
  this.addChild(this.instance)
  return this
end

lib.level = {}
lib.level.new = function(mode,startPosition,loop)
  local this = framework.MovieClip.new()
  this.instance = lib.cloud.new()
  this.instance.x = 265
  this.instance.y = 243

  this.timeline.addTween(framework.Tween.get(this.instance).wait(1).to({x=302.6},0).wait(1).to({x=340.2},0).wait(1).to({x=377.8},0).wait(1).to({x=415.4},0).wait(1).to({x=453},0).wait(1).to({x=406},0).wait(1).to({x=359},0).wait(1).to({x=312},0).wait(1).to({x=265},0).wait(1))
  return this
end

return lib
