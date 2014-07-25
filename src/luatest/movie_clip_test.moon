
export Main = {new: ->
  lib = dofile 'framework/test/lib.lua'
  level = lib.level.new!
  print level
  --mc = framework.MovieClip.new!
  --mc._tick!
  doFrame: (deltaMs)->
    level.draw!
}



