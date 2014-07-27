local Ticker
Ticker = {
new: maker (fps, initialListeners)=>
  @listeners = initialListeners or {}
  @timePerTick = 1000/(fps or 24)

  @addListener = (listener) ->
    table.insert @listeners, listener

  @_tick = (deltaMs) ->
    for l in *@listeners
      l._tick {}

  curTime = 0
  @update = (deltaMs) ->
    curTime += deltaMs
    while curTime>=@timePerTick
      curTime -= @timePerTick
      @._tick!





}

framework.Ticker = Ticker
