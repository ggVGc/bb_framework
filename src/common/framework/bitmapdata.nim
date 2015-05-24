when not defined(H_BITMAPDATA): 
  const 
    H_BITMAPDATA* = true
  import 
    rawbitmapdata

  type 
    BitmapData* {.importc: "BitmapData", header: "bitmapdata.h".} = object 
      width* {.importc: "width".}: cint
      height* {.importc: "height".}: cint
      glTexHandle* {.importc: "glTexHandle".}: GLuint

  proc bitmapDataInit*(data: ptr BitmapData; rawData: ptr RawBitmapData) {.
      importc: "bitmapDataInit", header: "bitmapdata.h".}
  proc bitmapDataCleanup*(data: ptr BitmapData) {.importc: "bitmapDataCleanup", 
      header: "bitmapdata.h".}

