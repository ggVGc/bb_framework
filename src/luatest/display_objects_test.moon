

export Main = {new: ->
  cam = framework.Camera.createDefault 960
  jumperLib = dofile 'flash/jumper.lua'

  bm1 = jumperLib.character_1.new!
  bm2 = jumperLib.character_1.new!
  bm1.gotoAndStop 'idle_up'
  bm2.gotoAndStop 'idle_up'
  bm1.x = 100
  bm1.y = 100
  bm2.y = 150
  bm1.addChild bm2


  doFrame: (deltaMs)->
    cam.apply!
    bm1.draw!
}



