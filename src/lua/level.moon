framework = framework or {}

framework.Level = {
new: maker (levelDefinition, texCreator, screenWidth, screenHeight) =>
  offsetParsers = {
    {
      c: (o,w,h)-> o.x,o.y = w/2, h/2
    },{
      t: (o,w,h)-> o.y=h,
      b: (o,w,h)-> o.y=0,
      r: (o,w,h)-> o.x=w,
      l: (o,w,h)-> o.x=0
    }
  }

  parseOffsets=(tex, originString)->
    ret = {x:0,y:0}
    return ret if not originString
    for groupIndex=1, #offsetParsers
      for k, parseFunc in pairs(offsetParsers[groupIndex])
        if string.find string.lower(originString), k
          parseFunc ret,tex.width,tex.height
    ret

  makeImageEntry=(data)->
    texName = data[1]..'.png'
    O = {
      x:0,y:0,
      texture: texCreator texName
    }
    if not O.texture
      print 'Invalid asset: '..texName
      return nil
    with O
      off = parseOffsets O.texture, data.origin
      .x = (data.left or data.right) and ((data.left and data.left-off.x) or screenWidth-off.x-data.right)
      .y = (data.bottom or data.top) and ((data.bottom and data.bottom-off.y) or screenHeight-off.y-data.top)

  images = pipe levelDefinition, {fun.map, makeImageEntry}, rejectNil, fun.totable
  updatableObjects = pipe images, {fun.filter, (o)->o.texture.update}, fun.totable

  @update = (deltaMs) ->
    o.texture.update deltaMs for o in *updatableObjects

  @draw =->
    for img in *images
      with img do .texture.draw(.x,.y,0,0)
}


framework.Level
