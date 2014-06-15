export DrawStates = {
new: maker (stateMap)=>
  curRenderObj = nil
  makeState= maker (renderObj)=>
    @set=->
      curRenderObj = renderObj


  @s = make => for k,v in pairs stateMap
    @[k] = makeState framework.Texture.fromFile v

  
  @draw=(x,y)->
    curRenderObj.draw x, y if curRenderObj

  @update=(deltaMs)->
    curRenderObj.update deltaMs if curRenderObj




}
