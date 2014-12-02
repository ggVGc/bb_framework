lib = {}
lib.level = {}
lib.level.new = function()
    local this = framework.MovieClip.new()
 
	

	-- Layer 2
	this.instance = lib.berry.new()
	this.instance.setTransform(448,199,1,1,0,0,0,28,32)
	this.instance._off = true

	this.timeline.addTween(framework.Tween.get(this.instance).wait(5).to({_off=false},0).wait(5))

	-- Layer 1
	this.instance_1 = lib.cloud.new()
	this.instance_1.setTransform(265,243,1,1,0,0,0,53,27)

	this.timeline.addTween(framework.Tween.get(this.instance_1).wait(1).to({x=302.6},0).wait(1).to({x=340.2},0).wait(1).to({x=377.8},0).wait(1).to({x=415.4},0).wait(1).to({x=453},0).wait(1).to({x=406},0).wait(1).to({x=359},0).wait(1).to({x=312},0).wait(1).to({x=265},0).wait(1))

    return this
end

lib.cloud_1 = {}
lib.cloud_1.new = function()
    local this = framework.cjs.Bitmap.new('flash/images/cloud.png')
 	
    return this
end

lib.jumper = {}
lib.jumper.new = function()
    local this = framework.cjs.Bitmap.new('flash/images/jumper.png')
 	
    return this
end

lib.cloud = {}
lib.cloud.new = function()
    local this = framework.Container.new()
 	

	-- Layer 1
	this.instance = lib.cloud_1.new()

	this.addChild(this.instance)
    return this
end

lib.berry = {}
lib.berry.new = function()
    local this = framework.Container.new()
 	

	-- Layer 1
	this.instance = lib.jumper.new()

	this.addChild(this.instance)
    return this
end

return lib
