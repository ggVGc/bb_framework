export Main = {new: ->
  sheet = framework.TextureSheet.fromFiles "data/sheet.png", "data/sheet.txt"
  frames = [sheet.createTexture 'jumper.png' for x=0,5]
  cam = framework.Camera.createDefault 960
  anim = framework.BitmapAnimation.new frames
  doFrame: (deltaMs)->
    cam.apply!
    anim.draw 200,200
}



