export Main = {
new: maker =>
  jumperLib = dofile 'flash/jumper/jumper.lua'
  jumperLib.sourceFolder = 'flash/jumper'
  mc = jumperLib.turtle_mask_idle_down_char4.new!
  @doFrame = (d)->
    mc._tick!
}
