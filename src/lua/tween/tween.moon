
Ticker = {
  addEventListener: ->

}

export Tween = {
NONE: 0
LOOP: 1
REVERSE: 2
IGNORE: {}
_tweens: {}
_plugins: {}
new: maker (target, props, pluginData)=>
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
  @_inited = false

  @ignoreGlobalPause = props and not not props.ignoreGlobalPause
  @loop = props and not not props.loop
  @duration = 0
  @pluginData = pluginData or {}
  @target = @_target
  @position = nil
  @passive = false


  if props
    if props.onChange then @.addEventListener "change", props.onChange
    if props.override then Tween.removeTweens target

  unless @_paused
    Tween._register @, true
  if props and props.position
    @.setPosition props.position, Tween.NONE


  @tick = (delta)->
    unless @._paused
      @.setPosition(@_prevPosition+delta)


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
          step = block ->
            for s in *@_steps
              return s if s > t
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
      @.dispatchEvent "change"
      return isEnd




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
  return if not target.tweenjs_count
  tweens = Tween._tweens
  for i=#tweens, 1, -1
      with tweens[i]
        if ._target == target
          ._paused = true
          tweens.splice i, 1
  target.tweenjs_count = 0


hasActiveTweens: (target) ->
  return target.tweenjs_count if target
  return Tween._tweens and not not #Tween._tweens


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
    for i=#tweens,0,-1
      if tweens[i] == tween
        tweens.splice i, 1
        return
}
