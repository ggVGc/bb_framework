
export Main = {new: ->
  lib = dofile('framework/testdata/bubble.lua')
  lib.sourceFolder = 'framework/testdata'
  bubble = lib.bubble.new!
  cam = framework.Camera.createDefault 960



  ticker = framework.Ticker.new 30, {bubble}
  doFrame: (deltaMs)->
    if deltaMs>50
      deltaMs = 50
    if framework.Input.charDown 'q'
      framework.exit!
    cam.apply!
    ticker.update deltaMs
    bubble.draw()
}



