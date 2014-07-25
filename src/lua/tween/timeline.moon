
local Timeline
Timeline = {
new: maker (tweens, labels, props) =>
    @ignoreGlobalPause = false
    @duration = 0
    @loop = false
    @position = nil
    @_paused = false
    @_tweens = {}
    @_labels = nil
    @_labelList = nil
    @_prevPosition = 0
    @_prevPos = -1
    @_useTicks = false
    if props
      @_useTicks = props.useTicks
      @loop = props.loop
      @ignoreGlobalPause = props.ignoreGlobalPause
      if props.onChange
        @addEventListener "change", props.onChange
    if tweens
      @addTween.apply(@, tweens)


    @setLabels = (o)->
      if o
        @_labels = o
      else
        @_labels = {}

    @setLabels labels

    @setPaused = (value)->
      @_paused = not not value
      framework.Tween._register(@, not value)

    @setPosition = (value, actionsMode)->
      if value < 0
        value = 0
      t = @loop and value%@duration or value
      ennd = (not @loop) and value >= @duration
      if t == @_prevPos
        return ennd
      @_prevPosition = value
      @_prevPos = t
      @position = @_prevPos
      for i=1,#@_tweens
        @_tweens[i].setPosition(t, actionsMode)
        if t ~= @_prevPos
          return false

      if ennd
        @setPaused true
      --@dispatchEvent "change"
      return ennd

    if props and props.paused
      @_paused=true
    else
      framework.Tween._register @, true
    if props and props.position~=nil
      @.setPosition props.position, framework.Tween.NONE
    
    @addTween = (...)->
      arguments = {...}
      l = #arguments
      if (l > 1)
        for i=1,l
          @.addTween(arguments[i])
        return arguments[1]
      elseif l == 0
        return nil
      tween = arguments[1]
      @.removeTween(tween)
      _.push @_tweens, tween
      tween.setPaused(true)
      tween._paused = false
      tween._useTicks = @_useTicks
      if tween.duration > @duration
        @duration = tween.duration
      if @_prevPos >= 0
        tween.setPosition(@_prevPos, framework.Tween.NONE)
      return tween

    
    @removeTween = (...) ->
      arguments = {...}
      l = #arguments
      if l > 1
        good = true
        for i=1,l
          good = good and @.removeTween(arguments[i])
        return good
      elseif l == 0
        return false

      tween = arguments[1]
      tweens = @_tweens
      i = #tweens+1
      while i>1
        i-=1
        if tweens[i] == tween
          table.remove tweens, i
          if tween.duration >= @duration
            @updateDuration!
          return true
      return false

    
    @addLabel = (label, position)->
      @_labels[label] = position
      list = @_labelList
      if list
        for i=1,#list
          if position < list[i].position
            break
        table.insert list, i,{label:label, position:position}

    
    
    
    --p.getLabels = function() {
        --var list = @_labelList;
        --if (!list) {
            --list = @_labelList = [];
            --var labels = @_labels;
            --for (var n in labels) {
                --list.push({label:n, position:labels[n]});
            --}
            --list.sort(function (a,b) { return a.position- b.position; });
        --}
        --return list;
    --};
    
    
    --p.getCurrentLabel = function() {
        --var labels = @.getLabels();
        --var pos = @position;
        --var l = labels.length;
        --if (l) {
            --for (var i = 0; i<l; i++) { if (pos < labels[i].position) { break; } }
            --return (i==0) ? null : labels[i-1].label;
        --}
        --return null;
    --};
    
    
    --@gotoAndPlay = (positionOrLabel)->
      --@setPaused false
      --@_goto positionOrLabel

    
    @gotoAndStop = (positionOrLabel)->
      @setPaused true
      @_goto positionOrLabel

    

    

    
    @updateDuration = ->
      @duration = 0
      for i=1,#@_tweens
        tween = @_tweens[i]
        if tween.duration > @duration
          @duration = tween.duration

    @tick = (delta)->
      @.setPosition(@_prevPosition+delta)

    @resolve = (positionOrLabel)->
      pos = tonumber positionOrLabel
      if not pos
        pos = @_labels[positionOrLabel]
      return pos

    @toString = -> "[Timeline]"

    @clone = -> error "Timeline can not be cloned."
    
    @_goto = (positionOrLabel)->
      pos = @.resolve(positionOrLabel)
      if pos ~= nil
        @.setPosition pos

}
framework.Timeline = Timeline
