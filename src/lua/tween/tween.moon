Ticker = {
  addEventListener: ->
}


INITIAL_OBJ_COUNT = 100

cloneProps = (props, outObj) ->
  for k,v in pairs props
    outObj[k] = v

makeStepObj = -> {
  active:false
  d: 0
  p0:{}
  e:nil
  p1:{}
  v:false
}



makeActionObj = -> {
  active: false
  f:nil
  p:nil
  o:nil
}


stepObjects = {}

getStepObj = (d, e, v)->
  local s
  for x in *stepObjects
    if not x.active
      s = x
  if not s
    s = makeStepObj!
    print 'making step obj'
    table.insert stepObjects, s
  s.d = d
  s.e = e
  s.v = v
  table.clear s.p0, s.p1
  s.active = true
  return s
actionObjects = {}

getActionObj = (f, p, o)->
  local a
  for x in *actionObjects
    if not x.active
      a = x
  if not a
    a = makeActionObj!
    print 'making action obj'
    table.insert actionObjects, a
  a.f = f
  a.p = p
  a.o = o
  a.active = true
  return a

paramObjects = {}

getParamObject = ->
  for p in *paramObjects
    if not p.active
      table.clear p
      p.active = true
      return p
  p = {active:true}
  table.insert paramObjects, p
  return p

for i=1,INITIAL_OBJ_COUNT
  table.insert stepObjects, makeStepObj!
for i=1,INITIAL_OBJ_COUNT
  table.insert actionObjects, makeActionObj!
for i=1,INITIAL_OBJ_COUNT
  table.insert paramObjects, {active:false}

export Tween
Tween = {
NONE: 0
LOOP: 1
REVERSE: 2
IGNORE: {}

reuseObjects: false

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


new: (initialTarget, props, pluginData) ->
  self = {}
  props = _.extend {}, Tween.defaultProps, props
  if props.onChange then self.addEventListener "change", props.onChange

  self._steps = {}
  self._actions = {}
  self._curQueueProps = {}
  self._initQueueProps = {}
  self.pluginData = pluginData or {}

  --self.reuseObjects = false

  self.reset = (newTarget) ->
    self.ignoreGlobalPause = props and not not props.ignoreGlobalPause
    self.loop = props and not not props.loop
    self.duration = 0
    self.position = nil
    self.passive = false

    self._paused = props and not not props.paused
    for s in *self._steps
      s.active = false
      s.d = 0
      s.v = false
      s.e = nil
      table.clear s.p0, s.p1
    for a in *self._actions
      if a.p
        table.clear a.p
      a.f = nil
      a.o = nil
      a.active = false
    table.clear self._curQueueProps, self._initQueueProps, self._steps, self._actions
    self._prevPosition = 0
    self._stepPosition = 0 -- this is needed by MovieClip.
    self._prevPos = -1
    self._target = newTarget
    self._useTicks = props and not not props.useTicks
    if props.override
      Tween.removeTweens newTarget
    --unless self._paused
      --Tween._register self, true

  self.reset(initialTarget or {})

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


  self._cloneProps = (props) ->
    o = {}
    for k,v in pairs props
      o[k] = v
    return o

  self.wait = (duration, passive) ->
    return self if (duration == nil or duration <= 0)
    local s
    if Tween.reuseObjects
      s = getStepObj!
      cloneProps self._curQueueProps, s.p0
      cloneProps self._curQueueProps, s.p1
    else
      s = makeStepObj!
      cloneProps self._curQueueProps, s.p0
      s.p1 = s.p0
    s.d = duration
    s.e = nil
    s.v = passive
    self._addStep s

  self.to = (props, duration, ease) ->
    duration = duration or 0
    if (duration==0/0 or duration < 0)
      duration = 0
    local s
    if Tween.reuseObjects
      s = getStepObj!
    else
      s = makeStepObj!
    s.d = duration or 0
    s.e = ease
    s.v = false
    cloneProps self._curQueueProps, s.p0
    cloneProps self._appendQueueProps(props), s.p1
    self._addStep s

  self.call = (callback, params=nil, scope=self._target)->
    if not params
      if Tween.reuseObjects
        params = getParamObject!
      else
        params = {}
      table.insert params, self
    local a
    if Tween.reuseObjects
      a = getActionObj!
    else
      a = makeActionObj!
    a.f = callback
    a.p = params
    a.o = scope
    self._addAction a


  self.set = (props, target)->
    if not target
      target = self._target
    local p
    if Tween.reuseObjects
      p = getParamObject!
    else
      p = {}
    table.insert p, props
    table.insert p, target
    local a
    if Tween.reuseObjects
      a = getActionObj!
    else
      a = makeActionObj!
    a.f = self._set
    a.p = p
    a.o = self
    self._addAction a

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
        table.clear action.p
        action.p.active = false

  self._appendQueueProps = (o)->
    local arr,oldValue,i, l, injectProps
    for n,_ in pairs o
      if self._initQueueProps[n]
        oldValue = self._curQueueProps[n]
      else
        oldValue = self._target[n]
        -- init plugins:
        --arr = Tween._plugins[n]
        --if arr
          --for i=1,#arr
            --oldValue = arr[i].init self, n, oldValue
        self._initQueueProps[n] = if oldValue then oldValue else nil

    for n,_ in pairs o
      oldValue = self._curQueueProps[n]
      --arr = Tween._plugins[n]
      --if arr
        --injectProps = injectProps or {}
        --for i=1,#arr
          ---- TODO: remove the check for .step in the next version. It's here for backwards compatibility.
          --if arr[i].step
            --arr[i].step self, n, oldValue, o[n], injectProps
      self._curQueueProps[n] = o[n]

    --if injectProps
      --self._appendQueueProps injectProps
    return self._curQueueProps


  self._addStep = (o) ->
    if o.d > 0
      o.t = self.duration
      table.insert self._steps, o
      self.duration += o.d
    return self

  self._set = (props, o)->
    for n,_ in pairs props
      o[n] = props[n]



  
  self._addAction = (o)->
    o.t = self.duration
    table.insert self._actions, o
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

    for n,_ in pairs self._initQueueProps
      v0 = p0[n]
      if v0 == nil
        v0 = self._initQueueProps[n]
        p0[n] = v0
      v1 = p1[n]
      if v1 == nil
        v1 = v0
        p1[n] = v1
      if v0 == v1 or ratio == 0 or ratio == 1 or not(type(v0)=='number')
        -- no interpolation - either at start, end, values don't change, or the value is non-numeric.
        v = if ratio == 1 then v1 else v0
      else
        v = v0+(v1-v0)*ratio

      ignore = false
      --arr = Tween._plugins[n]
      --if arr
        --for i=1,#arr
          --v2 = arr[i].tween self, n, v, p0, p1, ratio, (not not step) and p0==p1, not step
          --if v2 == Tween.IGNORE
            --ignore = true
          --else
            --v = v2

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
    table.insert tweens, tween
    if not Tween._inited and Ticker
      Ticker.addEventListener "tick", Tween
      Tween._inited = true
  else
    if target and target.tweenjs_count
      target.tweenjs_count-=1
    for i=#tweens,1,-1
      if tweens[i] == tween
        table.remove tweens, i, 1
        return
}

framework.Tween = Tween
