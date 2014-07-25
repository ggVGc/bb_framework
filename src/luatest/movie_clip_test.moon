
export Main = {new: ->
  lib = dofile 'framework/test/lib.lua'
  level = lib.level.new!
  print level
  --mc = framework.MovieClip.new!
  --mc._tick!
  level.gotoAndPlay(0)
  doFrame: (deltaMs)->
    level._tick {delta:deltaMs/2}
    print level.instance.x
    level.draw()
    --print 'frame'
}



