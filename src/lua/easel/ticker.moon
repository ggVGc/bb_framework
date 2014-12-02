local Ticker
Ticker = {
new: (fps, initialListeners) ->
  self = {}
  listeners = initialListeners or {}
  timePerTick = 1000/(fps or 24)

  --listenerCount = #initialListeners
  d = timePerTick/#initialListeners
  --print 'time', timePerTick, d
  times = {}
  for i=1,#initialListeners
    times[i] = i*math.floor(d)


  self.addListener = (listener) ->
    table.insert listeners, listener
    --listenerCount+=1
    cnt = #listeners
    times[cnt] = cnt*4

  self.removeListener = (listener)->
    for i=1,#listeners
      if listeners[i] == listener
        table.remove listeners, i
        --listenerCount-=1
        return true
    return false


  curTime = 0
  self.update = (deltaMs) ->
    if #times <= 0
      return
    ret = times[1]+deltaMs>=timePerTick
    for i=#listeners,1,-1 --iterate backwards in case a listeners removes itself during a tick
      times[i]+=deltaMs
      while times[i]>=timePerTick
        times[i] -= timePerTick
        listeners[i]._tick!
    return ret

  return self
}

framework.Ticker = Ticker
