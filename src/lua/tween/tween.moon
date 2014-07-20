Ticker = {
  addEventListener: ->
}

export Tween = {
NONE: 0
LOOP: 1
REVERSE: 2
IGNORE: {}

defaultProps: {
  useTicks: false
  loop: false
  override: false
  paused: false
  position: nil
}

_tweens: {}
_plugins: {}
_inited: false

new: maker (target, props, pluginData)=>
  @ignoreGlobalPause = props and not not props.ignoreGlobalPause
  @loop = props and not not props.loop
  @duration = 0
  @pluginData = pluginData or {}
  @target = @_target
  @position = nil
  @passive = false

  @_paused = props and not not props.paused
  @_curQueueProps = {}
  @_initQueueProps = {}
  @_steps = {}
  @_actions = {}
  @_prevPosition = 0
  @_stepPosition = 0 -- this is needed by MovieClip.
  @_prevPos = -1
  @_target = target
  @_useTicks = props and not not props.useTicks


  props = _.extend {}, Tween.defaultProps, props

  if props.onChange then @.addEventListener "change", props.onChange
  if props.override then Tween.removeTweens target

  unless @_paused
    Tween._register @, true
  if props.position
    @.setPosition props.position, Tween.NONE


  @tick = (delta)->
    unless @._paused
      @.setPosition(@_prevPosition+delta)

  @play = (tween)->
    @.setPaused false

  @pause = (tween)->
    @.setPaused true


  @wait = (duration, passive) ->
    return @ if (duration == nil or duration <= 0)
    o = @._cloneProps @_curQueueProps
    @._addStep {d:duration, p0:o, e:nil, p1:o, v:passive}

  @to = (props, duration, ease) ->
    if (_.isNaN duration or duration < 0)
      duration = 0
    @._addStep {
      d:duration or 0
      p0:@._cloneProps @_curQueueProps
      e:ease
      p1:@._cloneProps @._appendQueueProps(props)
    }


  @call = (callback, params={@}, scope=@_target)->
    @._addAction {f:callback, p:params, o:scope}


  @set = (props, target)->
    if not target
      target = @_target
    @._addAction {f:@_set, o:@, p:{props, target}}

  @setPaused = (value) ->
    if @_paused == not not value
      return @
    @_paused = not not value
    Tween._register @, not value
    return @

  -- tiny api (primarily for tool output):
  @w = @wait
  @t = @to
  @c = @call
  @s = @set

  @setPosition = (value, actionsMode=1)->
    if value and value < 0
      value = 0

    -- normalize position:
    t = value
    isEnd = false
    if t >= @duration
      if @loop
        t = t%@duration
      else
        t = @duration
        isEnd = true
    if t == @_prevPos
      return isEnd

    prevPos = @_prevPos
    @_prevPos = t
    @position = @_prevPos -- set new position in advance in case an action modifies position.
    @_prevPosition = value

    -- handle tweens:
    if @_target
      if isEnd
        -- addresses problems with an ending zero length step.
        @._updateTargetProps nil,1
      elseif #@_steps > 0
        -- find our new tween index:
        step = @_steps[#@_steps]
        for i=1,#@_steps
          if @_steps[i].t > t
            step = @_steps[i-1]
            break
        @_stepPosition = t-step.t
        @._updateTargetProps step, @_stepPosition/step.d

    -- run actions:
    if actionsMode != 0 and #@_actions> 0
      if @_useTicks
          -- only run the actions we landed on.
          @._runActions t,t
      elseif actionsMode == 1 and t<prevPos
          unless prevPos == @duration
            @._runActions prevPos, @duration
          @._runActions 0, t, true
      else
          @._runActions prevPos, t

    if isEnd then @.setPaused true

    -- TODO: Implement EventDispatcher and uncomment this
    -- @.dispatchEvent "change"

    return isEnd


  @_runActions = (startPos, endPos, includeStart)->
    sPos = startPos
    ePos = endPos
    i = 0
    j = #@_actions
    k = 1
    if startPos > endPos
      -- running backwards, flip everything:
      sPos = endPos
      ePos = startPos
      i = j
      k = 0
      j = k
    
    while i != j
      i+=k
      action = @_actions[i]
      pos = action.t
      if pos == ePos or (pos > sPos and pos < ePos) or (includeStart and pos == startPos)
        action.f action.o, action.p

  @_appendQueueProps = (o)->
    local arr,oldValue,i, l, injectProps
    for n,_ in pairs o
      if @_initQueueProps[n]
        oldValue = @_curQueueProps[n]
      else
        oldValue = @_target[n]
        -- init plugins:
        arr = Tween._plugins[n]
        if arr
          for i=1,#arr
            oldValue = arr[i].init @, n, oldValue
        @_initQueueProps[n] = if oldValue then oldValue else nil

    for n,_ in pairs o
      oldValue = @_curQueueProps[n]
      arr = Tween._plugins[n]
      if arr
        injectProps = injectProps or {}
        for i=1,#arr
          -- TODO: remove the check for .step in the next version. It's here for backwards compatibility.
          if arr[i].step
            arr[i].step @, n, oldValue, o[n], injectProps
      @_curQueueProps[n] = o[n]

    if injectProps
      @._appendQueueProps injectProps
    return @_curQueueProps


  @_addStep = (o) ->
    if o.d > 0
      o.t = @duration
      _.push @_steps, o
      @duration += o.d
    return @

  @_set = (props, o)->
    for n,_ in pairs props
      o[n] = props[n]


  @_cloneProps = (props) ->
    o = {}
    for k,v in pairs props
      o[k] = v
    return o

  
  @_addAction = (o)->
    o.t = @duration
    _.push @_actions, o
    return @

  @_updateTargetProps = (step, ratio) ->
    local p0,p1,v,v0,v1,arr
    if not step and ratio == 1
      -- GDS: when does this run? Just at the very end? Shouldn't.
      @passive = false
      p1 = @_curQueueProps
      p0 = p1
    else
      @passive = not not step.v
      return if @passive -- don't update props.
        
      -- apply ease to ratio.
      if step.e
        ratio = step.e ratio,0,1,1
      p0 = step.p0
      p1 = step.p1

    for n,dum in pairs @_initQueueProps
      v0 = p0[n]
      if v0 == nil
        v0 = @_initQueueProps[n]
        p0[n] = v0
      v1 = p1[n]
      if v1 == nil
        v1 = v0
        p1[n] = v1
      if v0 == v1 or ratio == 0 or ratio == 1 or not _.isNumber(v0)
        -- no interpolation - either at start, end, values don't change, or the value is non-numeric.
        v = if ratio == 1 then v1 else v0
      else
        v = v0+(v1-v0)*ratio

      ignore = false
      arr = Tween._plugins[n]
      if arr
        for i=1,#arr
          v2 = arr[i].tween @, n, v, p0, p1, ratio, (not not step) and p0==p1, not step
          if v2 == Tween.IGNORE
            ignore = true
          else
            v = v2

      if not ignore
        @_target[n] = v

get: (target, props, pluginData, override) ->
  if override then Tween.removeTweens(target)
  Tween.new(target, props, pluginData)


tick: (delta, paused) ->
  tweens = _.slice(Tween._tweens) -- copy to avoid race conditions.
  for i=#tweens, 1, -1
    with tweens[i] do unless ._paused or (paused and not .ignoreGlobalPause)
      .tick(._useTicks and 1 or delta)


handleEvent: (event) ->
  if event.type == "tick"
    Tween.tick event.delta, event.paused


removeTweens: (target) ->
  return if target.tweenjs_count == 0
  tweens = Tween._tweens
  for i=#tweens, 1, -1
      with tweens[i]
        if ._target == target
          ._paused = true
          table.remove tweens, i, 1
  target.tweenjs_count = 0


hasActiveTweens: (target) ->
  return target.tweenjs_count if target
  return Tween._tweens and #Tween._tweens>0

installPlugin: (plugin, properties) ->
  priority = plugin.priority
  if priority == nil
    priority = 0
    plugin.priority = priority
  p=Tween._plugins
  for i=1,#properties
    n = properties[i]
    if not p[n]
      p[n] = {plugin}
    else
      arr = p[n]
      j=1
      while j<=#arr
        if priority < arr[j].priority
          break
      table.remove p[n], j, 0
      table.insert p[n], 0, plugin


_register: (tween, value) ->
  target = tween._target
  tweens = Tween._tweens
  if value
    if target
      target.tweenjs_count = let target.tweenjs_count,=> @ and @+1 or 1
    _.push tweens, tween
    if not Tween._inited and Ticker
      Ticker.addEventListener "tick", Tween
      Tween._inited = true
  else
    if target
      target.tweenjs_count-=1
    for i=#tweens,1,-1
      if tweens[i] == tween
        table.remove tweens, i, 1
        return
}
