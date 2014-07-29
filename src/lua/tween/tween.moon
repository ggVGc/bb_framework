Ticker = {
  addEventListener: ->
}

export Tween
Tween = {
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

new: (target, props, pluginData) ->
  self = {}
  self.ignoreGlobalPause = props and not not props.ignoreGlobalPause
  self.loop = props and not not props.loop
  self.duration = 0
  self.pluginData = pluginData or {}
  self.target = self._target
  self.position = nil
  self.passive = false

  self._paused = props and not not props.paused
  self._curQueueProps = {}
  self._initQueueProps = {}
  self._steps = {}
  self._actions = {}
  self._prevPosition = 0
  self._stepPosition = 0 -- this is needed by MovieClip.
  self._prevPos = -1
  self._target = target
  self._useTicks = props and not not props.useTicks


  props = _.extend {}, Tween.defaultProps, props

  if props.onChange then self.addEventListener "change", props.onChange
  if props.override then Tween.removeTweens target

  unless self._paused
    Tween._register self, true
  if props.position
    self.setPosition props.position, Tween.NONE


  self.tick = (delta)->
    unless self._paused
      self.setPosition(self._prevPosition+delta)

  self.play = (tween)->
    self.setPaused false

  self.pause = (tween)->
    self.setPaused true


  self.wait = (duration, passive) ->
    return self if (duration == nil or duration <= 0)
    o = self._cloneProps self._curQueueProps
    self._addStep {d:duration, p0:o, e:nil, p1:o, v:passive}

  self.to = (props, duration, ease) ->
    duration = duration or 0
    if (_.isNaN duration or duration < 0)
      duration = 0
    self._addStep {
      d:duration or 0
      p0:self._cloneProps self._curQueueProps
      e:ease
      p1:self._cloneProps self._appendQueueProps(props)
    }


  self.call = (callback, params={self}, scope=self._target)->
    self._addAction {f:callback, p:params, o:scope}


  self.set = (props, target)->
    if not target
      target = self._target
    self._addAction {f:self._set, o:self, p:{props, target}}

  self.setPaused = (value) ->
    if self._paused == not not value
      return self
    self._paused = not not value
    Tween._register self, not value
    return self

  -- tiny api (primarily for tool output):
  self.w = self.wait
  self.t = self.to
  self.c = self.call
  self.s = self.set

  self.setPosition = (value, actionsMode=1)->
    if value and value < 0
      value = 0

    -- normalize position:
    t = value
    isEnd = false
    if t >= self.duration
      if self.loop
        t = t%self.duration
      else
        t = self.duration
        isEnd = true
    if t == self._prevPos
      return isEnd

    prevPos = self._prevPos
    self._prevPos = t
    self.position = self._prevPos -- set new position in advance in case an action modifies position.
    self._prevPosition = value

    -- handle tweens:
    if self._target
      if isEnd
        -- addresses problems with an ending zero length step.
        self._updateTargetProps nil,1
      elseif #self._steps > 0
        -- find our new tween index:
        step = self._steps[#self._steps]
        for i=1,#self._steps
          if self._steps[i].t > t
            step = self._steps[i-1]
            break
        self._stepPosition = t-step.t
        self._updateTargetProps step, self._stepPosition/step.d

    -- run actions:
    if actionsMode != 0 and #self._actions> 0
      if self._useTicks
          -- only run the actions we landed on.
          self._runActions t,t
      elseif actionsMode == 1 and t<prevPos
          unless prevPos == self.duration
            self._runActions prevPos, self.duration
          self._runActions 0, t, true
      else
          self._runActions prevPos, t

    if isEnd then self.setPaused true

    -- TODO: Implement EventDispatcher and uncomment this
    -- self.dispatchEvent "change"

    return isEnd


  self._runActions = (startPos, endPos, includeStart)->
    sPos = startPos
    ePos = endPos
    i = 0
    j = #self._actions
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
      action = self._actions[i]
      pos = action.t
      if pos == ePos or (pos > sPos and pos < ePos) or (includeStart and pos == startPos)
        action.f action.o, action.p

  self._appendQueueProps = (o)->
    local arr,oldValue,i, l, injectProps
    for n,_ in pairs o
      if self._initQueueProps[n]
        oldValue = self._curQueueProps[n]
      else
        oldValue = self._target[n]
        -- init plugins:
        arr = Tween._plugins[n]
        if arr
          for i=1,#arr
            oldValue = arr[i].init self, n, oldValue
        self._initQueueProps[n] = if oldValue then oldValue else nil

    for n,_ in pairs o
      oldValue = self._curQueueProps[n]
      arr = Tween._plugins[n]
      if arr
        injectProps = injectProps or {}
        for i=1,#arr
          -- TODO: remove the check for .step in the next version. It's here for backwards compatibility.
          if arr[i].step
            arr[i].step self, n, oldValue, o[n], injectProps
      self._curQueueProps[n] = o[n]

    if injectProps
      self._appendQueueProps injectProps
    return self._curQueueProps


  self._addStep = (o) ->
    if o.d > 0
      o.t = self.duration
      _.push self._steps, o
      self.duration += o.d
    return self

  self._set = (props, o)->
    for n,_ in pairs props
      o[n] = props[n]


  self._cloneProps = (props) ->
    o = {}
    for k,v in pairs props
      o[k] = v
    return o

  
  self._addAction = (o)->
    o.t = self.duration
    _.push self._actions, o
    return self

  self._updateTargetProps = (step, ratio) ->
    local p0,p1,v,v0,v1,arr
    if not step and ratio == 1
      -- GDS: when does this run? Just at the very end? Shouldn't.
      self.passive = false
      p1 = self._curQueueProps
      p0 = p1
    else
      self.passive = not not step.v
      return if self.passive -- don't update props.
        
      -- apply ease to ratio.
      if step.e
        ratio = step.e ratio,0,1,1
      p0 = step.p0
      p1 = step.p1

    for n,dum in pairs self._initQueueProps
      v0 = p0[n]
      if v0 == nil
        v0 = self._initQueueProps[n]
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
          v2 = arr[i].tween self, n, v, p0, p1, ratio, (not not step) and p0==p1, not step
          if v2 == Tween.IGNORE
            ignore = true
          else
            v = v2

      if not ignore
        self._target[n] = v

  return self

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
      if target.tweenjs_count
        target.tweenjs_count = target.tweenjs_count+1
      else
        target.tweenjs_count = 1
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

framework.Tween = Tween
