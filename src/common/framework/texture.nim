when not defined(H_TEXTURE_H): 
  const 
    H_TEXTURE_H* = true
  import 
    rect

  type 
    BitmapData* {.importc: "BitmapData", header: "texture.h".} = object 
    
  type 
    Texture* {.importc: "Texture", header: "texture.h".} = object 
      width* {.importc: "width".}: cint
      height* {.importc: "height".}: cint
      uvCoords* {.importc: "uvCoords".}: array[12, cfloat]
      data* {.importc: "data".}: ptr BitmapData

  proc textureInit*(tex: ptr Texture; data: ptr BitmapData; sourceRect: Rekt) {.
      importc: "textureInit", header: "texture.h".}

