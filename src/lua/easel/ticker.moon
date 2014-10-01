local Ticker
Ticker = {
new: (fps, initialListeners) ->
  self = {}
  listeners = initialListeners or {}
  timePerTick = 1000/(fps or 24)

  listenerCount = #initialListeners
  d = timePerTick/listenerCount
  --print 'time', timePerTick, d
  times = {}
  for i=1,#initialListeners
    times[i] = i*math.floor(d)


  self.addListener = (listener) ->
    table.insert listeners, listener
    listenerCount+=1
    times[listenerCount] = listenerCount*4

  props = {}
  curTime = 0
  self.update = (deltaMs) ->
    --print 'update'
    ret = times[1]+deltaMs>=timePerTick
    for i=1, listenerCount
      times[i]+=deltaMs
      if times[i]>=timePerTick
        times[i] -= timePerTick
        listeners[i]._tick props
        --print 'tick', i
    return ret

  return self
}

framework.Ticker = Ticker
