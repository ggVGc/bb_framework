
local Timeline
Timeline = {
new: (tweens, labels, props) ->
  self = {}
  self.ignoreGlobalPause = false
  self.duration = 0
  self.loop = false
  self.position = nil
  self._paused = false
  self._tweens = {}
  self._labels = nil
  self._labelList = nil
  self._prevPosition = 0
  self._prevPos = -1
  self._useTicks = false
  if props
    self._useTicks = props.useTicks
    self.loop = props.loop
    self.ignoreGlobalPause = props.ignoreGlobalPause
    if props.onChange
      self.addEventListener "change", props.onChange
  if tweens
    self.addTween.apply(self, tweens)


  self.setLabels = (o)->
    if o
      self._labels = o
    else
      self._labels = {}

  self.setLabels labels

  self.setPaused = (value)->
    self._paused = not not value
    framework.Tween._register(self, not value)

  self.setPosition = (value, actionsMode)->
    if value < 0
      value = 0
    t = self.loop and value%self.duration or value
    ennd = (not self.loop) and value >= self.duration
    if t == self._prevPos
      return ennd
    self._prevPosition = value
    self._prevPos = t
    self.position = self._prevPos
    for i=1,#self._tweens
      self._tweens[i].setPosition(t, actionsMode)
      if t ~= self._prevPos
        return false

    if ennd
      self.setPaused true
    --self.dispatchEvent "change"
    return ennd

  if props and props.paused
    self._paused=true
  else
    framework.Tween._register self, true
  if props and props.position~=nil
    self.setPosition props.position, framework.Tween.NONE
  
  self.addTween = (tween, ...)->
    self.removeTween(tween)
    table.insert self._tweens, tween
    tween.setPaused(true)
    tween._paused = false
    tween._useTicks = self._useTicks
    if tween.duration > self.duration
      self.duration = tween.duration
    if self._prevPos >= 0
      tween.setPosition(self._prevPos, framework.Tween.NONE)
    if select('#', ...)>0
      return self.addTween ...
    else
      return tween

  
  self.removeTween = (tween, ...) ->
    tweens = self._tweens
    i = #tweens+1
    ret = false
    while i>1
      i-=1
      if tweens[i] == tween
        table.remove tweens, i
        if tween.duration >= self.duration
          self.updateDuration!
        ret = true
        break

    if select('#', ...)>0
      return self.removeTween ...
    else
      return ret

  
  self.addLabel = (label, position)->
    self._labels[label] = position
    list = self._labelList
    if list
      for i=1,#list
        if position < list[i].position
          break
      table.insert list, i,{label:label, position:position}

  
  
  
  --p.getLabels = function() {
      --var list = self._labelList;
      --if (!list) {
          --list = self._labelList = [];
          --var labels = self._labels;
          --for (var n in labels) {
              --list.push({label:n, position:labels[n]});
          --}
          --list.sort(function (a,b) { return a.position- b.position; });
      --}
      --return list;
  --};
  
  
  --p.getCurrentLabel = function() {
      --var labels = self.getLabels();
      --var pos = self.position;
      --var l = labels.length;
      --if (l) {
          --for (var i = 0; i<l; i++) { if (pos < labels[i].position) { break; } }
          --return (i==0) ? null : labels[i-1].label;
      --}
      --return null;
  --};
  
  
  self.gotoAndPlay = (positionOrLabel)->
    self.setPaused false
    self._goto positionOrLabel

  
  self.gotoAndStop = (positionOrLabel)->
    self.setPaused true
    self._goto positionOrLabel

  

  

  
  self.updateDuration = ->
    self.duration = 0
    for i=1,#self._tweens
      tween = self._tweens[i]
      if tween.duration > self.duration
        self.duration = tween.duration

  self.tick = (delta)->
    self.setPosition(self._prevPosition+delta)

  self.resolve = (positionOrLabel)->
    pos = tonumber positionOrLabel
    if not pos
      pos = self._labels[positionOrLabel]
    return pos

  self.toString = -> "[Timeline]"

  self.clone = -> error "Timeline can not be cloned."
  
  self._goto = (positionOrLabel)->
    pos = self.resolve(positionOrLabel)
    if pos ~= nil
      self.setPosition pos

  return self

}
framework.Timeline = Timeline
