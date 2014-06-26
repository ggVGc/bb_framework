framework = framework or {}


framework.AssetLoader = AHOO {
  --new: maker () =>
  --texCreator=(path, args)->
    --if sheet.exists path
      --sheet.createTexture path
    --else
      --img = framework.Texture.fromFile 'data/'..path, false
      --if not img
        --path = string.sub path, 1, path\lastIndexOf('%.')-1
        --frame1 = framework.Texture.fromFile 'data/'..path..'/1.png', false
        --if frame1
          --frames = for index in fun.duplicate!
            --tex = framework.Texture.fromFile 'data/'..path..'/'..tostring(index)..'.png', false
            --if not tex
              --break
            --tex
          --framework.BitmapAnimation.new frames, args.time

--.getAnimationFrames = (path) ->
  --print 'asd'

getAnimation: (path, ...)->
  print ME
  --framework.BitmapAnimation.new (.getAnimationFrames path), ...


}


framework.AssetLoader
