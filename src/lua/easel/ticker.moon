local Ticker
Ticker = {
new: (fps, initialListeners) ->
  self = {}
  self.listeners = initialListeners or {}
  self.timePerTick = 1000/(fps or 24)

  self.addListener = (listener) ->
    table.insert self.listeners, listener

  self._tick = (deltaMs) ->
    for l in *self.listeners
      l._tick {}

  curTime = 0
  self.update = (deltaMs) ->
    curTime += deltaMs
    while curTime>=self.timePerTick
      curTime -= self.timePerTick
      self._tick!

  return self
}

framework.Ticker = Ticker
