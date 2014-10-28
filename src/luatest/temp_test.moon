
export Main = { new:maker =>
  jumperLib = dofile 'flash/jumper/jumper.lua'
  jumperLib.sourceFolder = 'flash/jumper'
  levelLib = dofile 'flash/level/level.lua'
  levelLib.sourceFolder = 'flash/level'
  levelBackLib = dofile 'flash/level_back/level_back.lua'
  levelBackLib.sourceFolder = 'flash/level_back'
  levelBack = levelBackLib.level_back_1.new!
  j = jumperLib.char_3.new!
  cam = framework.Camera.createDefault 960
  j.x = 100
  j.y = 100
  levelMid = levelLib.level_middle.new!
  @update = ->
    j._tick!
    levelBack._tick!
    levelMid._tick!
  @draw = ->
    cam.apply!
    levelBack.draw!
    levelMid.draw!
    j.draw!
}
