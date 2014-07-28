
export Main = {new: ->
  --lib = dofile 'framework/test/lib.lua'
  --level = lib.level.new!
  mc = framework.MovieClip.new!
  o = {foo:123, bar:8888}
  mc.timeline.addTween(framework.Tween.get(o).to({bar:4444}))
  --mc.foo = 10
  mc._tick!
  print o.foo, o.bar
  --level.gotoAndPlay(0)
  doFrame: (deltaMs)->
    --level._tick {}
    --level.draw()
    --print 'frame'
}



