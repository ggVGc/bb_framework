export Main = {new: ->
  a = {5,3,4,6,7,8,4,23,44,2,3,5,6,6,2}
  s = block ->
    for x in *a
      return x if x>10

  print s

  doFrame: (deltaMs)->
    t = Tween.get {}
    Tween.tick 10, false
}



