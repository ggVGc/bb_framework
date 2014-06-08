export Main = {new: ->
  sheet = framework.TextureSheet.fromFiles("data/sheet.png", "data/sheet.txt")
  frame = sheet.createTexture 'jumper.png'
  cam = framework.Camera.createDefault 960
  i =0
  doFrame: (deltaMs)->
    i+=1
    print 'draw', i
    cam.apply!
    frame.draw()
    return 0
}



