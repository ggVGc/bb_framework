
export Main = {new: ->
  lib = dofile 'framework/test/lib.lua'
  level = lib.level.new!
  --mc = framework.MovieClip.new!
  --mc._tick!
  level.gotoAndPlay(0)
  doFrame: (deltaMs)->
    level._tick {}
    level.draw()
    --print 'frame'
}



