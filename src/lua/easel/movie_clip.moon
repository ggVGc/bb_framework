
 
local MovieClip
MovieClip = {
INDEPENDENT: "independent"
SINGLE_FRAME: "single"
SYNCHED: "synched"
	
new: maker (initialMode, initialStartPosition, initialLoop, labels)=>
  @mode = initialMode or MovieClip.INDEPENDENT
  @startPosition = initialStartPosition or 0
  @loop = initialLoop or true
  @currentFrame = 0
  @timeline = nil
  @paused = false
  @actionsEnabled = true
  @autoReset = true
  @frameBounds = nil
  @framerate = nil

  @_synchOffset = 0
  @_prevPos = -1
  @_prevPosition = 0
  @_t = 0
  @_managed = {}

  container = framework.Container.new!

  props = {paused:true, position:@startPosition, useTicks:true}
  @timeline = framework.Timeline.new(nil, labels, props)
  
  
  @isVisible = ->
    not not (@visible and @alpha > 0 and @scaleX ~= 0 and @scaleY ~= 0)
  

  contDraw = container.draw
  @draw = (sceneHeight, ctx, ignoreCache)->
    --if @DisplayObject_draw ctx, ignoreCache
      --return true
    @._updateTimeline!
    contDraw(sceneHeight, ctx, ignoreCache)
    true
  
  setmetatable(@, {__newindex:container, __index:container})

  @play = ->
    @paused = false
  
  @stop = ->
    @paused = true
  
  @gotoAndPlay = (positionOrLabel)->
    @paused = false
    @_goto positionOrLabel
  
  @gotoAndStop = (positionOrLabel)->
    @paused = true
    @_goto positionOrLabel
  
  
  @advance = (time)->
    return unless @mode == MovieClip.INDEPENDENT
    
    fps = @framerate
    o = @
    o = @parent
    while o and fps == nil
      o = @parent
      if o.mode == MovieClip.INDEPENDENT
        fps = o._framerate
    @_framerate = fps
    
    local t
    if fps ~= nil and fps ~= -1 and time ~= nil
      t = time/(1000/fps) + @_t
    else
      t = 1

    frames = t
    @_t = t-frames
    
    while frames>0
      frames -= 1
      if not @paused
        if @_prevPos < 0
          @_prevPosition = 0
        else
          @_prevPosition = @_prevPosition+1
        @._updateTimeline!
  

  @getLabels = ->
    @timeline.getLabels!
  
  
  @getCurrentLabel = ->
    @._updateTimeline!
    @timeline.getCurrentLabel!
  
  @clone = ->
    error "MovieClip cannot be cloned."
  
  @toString = ->
    "[MovieClip (name=#{@name})]"

  contTick = container._tick
  @_tick = (props)->
    @.advance(props and props.delta)
    contTick(props)
  
  @_goto = (positionOrLabel)->
    pos = @timeline.resolve positionOrLabel
    return if pos == nil

    if @_prevPos == -1
      @_prevPos = NaN
    @_prevPosition = pos
    @_t = 0
    @._updateTimeline!
  
  
  @_reset = ->
    @_prevPos = -1
    @_t = 0
    @currentFrame = 0
  
  @_updateTimeline = ->
      tl = @timeline
      synched = @mode ~= MovieClip.INDEPENDENT
      tl.loop = @loop==nil and true or @loop

      if synched
        tl.setPosition(@startPosition + (@mode==MovieClip.SINGLE_FRAME and 0 or @_synchOffset), framework.Tween.NONE)
      else
        tl.setPosition(@_prevPos < 0 and 0 or @_prevPosition, not @actionsEnabled and framework.Tween.NONE or nil)

      @_prevPosition = tl._prevPosition
      return if @_prevPos == tl._prevPos

      @_prevPos = tl._prevPos
      @currentFrame = @_prevPos

      for n in pairs @_managed
        @_managed[n] = 1

      tweens = tl._tweens
      for tween in *tweens
        target = tween._target
        continue if target == @ or tween.passive
        offset = tween._stepPosition

        --if instanceof(target, framework.DisplayObject)
        @._addManagedChild(target, offset)
        --else
          --@._setState(target.state, offset)

      kids = @children
      for i=#kids, 1, -1
        id = kids[i].id
        if @_managed[id] == 1
          @.removeChildAt i
          @_managed[id] = nil

  
  @_setState = (state, offset)->
    return unless state
    for i=#state, 1, -1
      o = state[i]
      target = o.t
      props = o.p
      for k, v in pairs props
        target[k] = v
      @._addManagedChild target, offset

  
  @_addManagedChild = (child, offset)->
    return if child._off
    @.addChildAt child, 1

    --if instanceof(child, MovieClip)
      --child._synchOffset = offset
      --if child.mode == MovieClip.INDEPENDENT and child.autoReset and not @_managed[child.id]
        --child._reset!
    @_managed[child.id] = 2
  
  
  --@_getBounds = (matrix, ignoreTransform)->
      --bounds = @DisplayObject_getBounds!
      --if not bounds
        --@_updateTimeline!
        --if @frameBounds
          --bounds = @_rectangle.copy(@frameBounds[@currentFrame+1])
      --if bounds
        --return @._transformBounds(bounds, matrix, ignoreTransform)
      --return @.Container__getBounds(matrix, ignoreTransform)

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
