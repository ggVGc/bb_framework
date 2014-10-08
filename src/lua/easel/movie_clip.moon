
local MovieClip
MovieClip = {
tickCount: 0
INDEPENDENT: "independent"
SINGLE_FRAME: "single"
SYNCHED: "synched"
	
new: (initialMode, initialStartPosition, initialLoop, labels) ->
  self = {}
  self.mode = initialMode or MovieClip.INDEPENDENT
  self.startPosition = initialStartPosition or 0
  self.loop = true
  if initialLoop == false
    self.loop = false
  self.currentFrame = 0
  self.timeline = nil
  self.paused = false
  self.actionsEnabled = true
  self.autoReset = true
  self.frameBounds = nil
  self.framerate = nil

  self._synchOffset = 0
  self._prevPos = -1
  self._prevPosition = 0
  self._t = 0
  self._managed = {}

  self.isMovieClip = true


  container = framework.Container.new!

  props = {paused:true, position:self.startPosition, useTicks:true}
  self.timeline = framework.Timeline.new(nil, labels, props)
  
  
  self.isVisible = ->
    not not self.visible
  

  contDraw = container.draw
  self.draw = ->
    --if self.DisplayObject_draw ctx, ignoreCache
      --return true
    self._updateTimeline!
    contDraw!
    true
  

  self.play = ->
    self.paused = false
  
  self.stop = ->
    self.paused = true
  
  self.gotoAndPlay = (positionOrLabel)->
    self.paused = false
    self._goto positionOrLabel
  
  self.gotoAndStop = (positionOrLabel)->
    self.paused = true
    self._goto positionOrLabel
  
  
  self.advance = (time)->
    return unless self.mode == MovieClip.INDEPENDENT
    
    -- Keep the commented code!
    -- Disabled time param for now, and always step one
    -- Also don't traverse parent hierarchy and set fps

    --fps = self.framerate
    --o = self
    --o = self.parent
    --while o and fps == nil
      --o = o.parent
      --if o and o.mode == MovieClip.INDEPENDENT
        --fps = o._framerate
    --self._framerate = fps
    
    --local t
    --if fps ~= nil and fps ~= -1 and time ~= nil
      --t = time/(1000/fps) + self._t
    --else
      --t = 1

    --frames = t
    --self._t = t-frames
    
    --frames = 1
    --while frames>0
      --frames -= 1
    if not self.paused
      if self._prevPos < 0
        self._prevPosition = 0
      else
        self._prevPosition = self._prevPosition+1
      self._updateTimeline!
  

  self.getLabels = ->
    self.timeline.getLabels!
  
  
  self.getCurrentLabel = ->
    self._updateTimeline!
    self.timeline.getCurrentLabel!
  
  self.clone = ->
    error "MovieClip cannot be cloned."
  
  self.toString = ->
    "[MovieClip (name=#{self.name})]"

  contTick = container._tick
  self._tick = (props)->
    MovieClip.tickCount+=1
    self.advance(props and props.delta)
    contTick(props)
  
  self._goto = (positionOrLabel)->
    pos = self.timeline.resolve positionOrLabel
    return if pos == nil

	-- prevent _updateTimeline from overwriting the new position because of a reset:
    if self._prevPos == -1
      -- 0/0/0
      self._prevPos = 0/0
    self._prevPosition = pos
    self._t = 0
    self._updateTimeline!
  
  
  self._reset = ->
    self._prevPos = -1
    self._t = 0
    self.currentFrame = 0
  
  self._updateTimeline = ->
      tl = self.timeline
      synched = self.mode ~= MovieClip.INDEPENDENT
      tl.loop = self.loop==nil and true or self.loop

      isEnd = false
      if synched
        isEnd = tl.setPosition(self.startPosition + (self.mode==MovieClip.SINGLE_FRAME and 0 or self._synchOffset), framework.Tween.NONE)
      else
        isEnd = tl.setPosition(self._prevPos < 0 and 0 or self._prevPosition, not self.actionsEnabled and framework.Tween.NONE or nil)

      self._prevPosition = tl._prevPosition

      return if self._prevPos == tl._prevPos

      self._prevPos = tl._prevPos
      self.currentFrame = self._prevPos

      for n in pairs self._managed
        self._managed[n] = 1

      tweens = tl._tweens
      for tween in *tweens
        target = tween._target
        continue if target == self or tween.passive
        offset = tween._stepPosition

        if target.isDisplayObj
          self._addManagedChild(target, offset)
        else
          self._setState(target.state, offset)

      kids = self.children
      for i=#kids, 1, -1
        id = kids[i].id
        if self._managed[id] == 1
          self.removeChildAt i
          self._managed[id] = nil

  
  self._setState = (state, offset)->
    return unless state
    for i=#state, 1, -1
      o = state[i]
      target = o.t
      props = o.p
      if props
        for k, v in pairs props
          target[k] = v

      self._addManagedChild target, offset

  
  self._addManagedChild = (child, offset)->
    return if child._off
    self.addChildAt child, 1

    if child.isMovieClip
      child._synchOffset = offset
      if child.mode == MovieClip.INDEPENDENT and child.autoReset and not self._managed[child.id]
        child._reset!
    self._managed[child.id] = 2

  setmetatable(self, {__newindex:container, __index:container})
  return self
  
  
  --self._getBounds = (matrix, ignoreTransform)->
      --bounds = self.DisplayObject_getBounds!
      --if not bounds
        --self._updateTimeline!
        --if self.frameBounds
          --bounds = self._rectangle.copy(self.frameBounds[self.currentFrame+1])
      --if bounds
        --return self._transformBounds(bounds, matrix, ignoreTransform)
      --return self.Container__getBounds(matrix, ignoreTransform)

--createjs.MovieClip = MovieClip;
  
  --var MovieClipPlugin = function() {
    --throw("MovieClipPlugin cannot be instantiated.")
  --};
  
  
  --MovieClipPlugin.priority = 100; // very high priority, should run first

  
  --MovieClipPlugin.install = function() {
      --createjs.Tween.installPlugin(MovieClipPlugin, ["startPosition"]);
  --};
  
  
  --MovieClipPlugin.init = function(tween, prop, value) {
      --return value;
  --};
  
  
  --MovieClipPlugin.step = function() {
      --// unused.
  --};

  
  --MovieClipPlugin.tween = function(tween, prop, value, startValues, endValues, ratio, wait, end) {
      --if (!(tween.target instanceof MovieClip)) { return value; }
      --return (ratio == 1 ? endValues[prop] : startValues[prop]);
  --};

  --MovieClipPlugin.install();

}
framework.MovieClip = MovieClip
