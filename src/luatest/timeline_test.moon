
export Main = {new: ->
  obj = {x:1}
  --t.wait(2000).call(f).to({x:100}, 5000).wait(1).to({x:30}, 10000)
  t = framework.Tween.get obj
  t.wait 200
  t.to {x:200}, 3000
  t.to {x:1}, 500

  tl = framework.Timeline.new!
  tl.addTween t
  tl.setPaused false

  doFrame: (deltaMs)->
    if deltaMs<1000
      framework.Tween.tick deltaMs, false
    print obj.x
}



