when not defined(H_RAWBITMAPDATA_H): 
  const 
    H_RAWBITMAPDATA_H* = true
  type 
    RawBitmapData* {.importc: "RawBitmapData", header: "rawbitmapdata.h".} = object 
      data* {.importc: "data".}: ptr cuchar # RGBA
      width* {.importc: "width".}: cuint
      height* {.importc: "height".}: cuint

  proc rawBitmapDataCleanup*(rawData: ptr RawBitmapData) {.
      importc: "rawBitmapDataCleanup", header: "rawbitmapdata.h".}

