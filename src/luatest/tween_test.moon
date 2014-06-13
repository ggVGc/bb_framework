export Main = {new: ->
  obj = {x:1}
  t = Tween.get obj, {loop:true}
  --t.wait(2000).call(f).to({x:100}, 5000).wait(1).to({x:30}, 10000)
  with t
    .wait 1000
    .to {x:200}, 3000
    .to {x:1}, 500
  doFrame: (deltaMs)->
    if deltaMs<1000
      Tween.tick deltaMs, false
      print obj.x
}



