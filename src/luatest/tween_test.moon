export Main = {new: ->
  obj = {}
  --t.wait(2000).call(f).to({x:100}, 5000).wait(1).to({x:30}, 10000)
  with Tween.get obj
    .wait 1000
    .to {x:200}, 3000
    .to {x:1}, 500

  doFrame: (deltaMs)->
    if deltaMs<1000
      Tween.tick deltaMs, false
      print obj.x
}



