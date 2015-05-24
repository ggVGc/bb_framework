when not defined(H_RESOURCE_LOADING): 
  const 
    H_RESOURCE_LOADING* = true
  import 
    rawbitmapdata

  proc setResourcePath*(path: cstring) {.importc: "setResourcePath", 
      header: "resource_loading.h".}
  proc loadBytesIntoBuffer*(inPath: cstring; data: ptr cuchar; bufferSize: cint): cint {.
      importc: "loadBytesIntoBuffer", header: "resource_loading.h".}
  proc loadBytes*(path: cstring; sz: ptr cint): ptr cuchar {.
      importc: "loadBytes", header: "resource_loading.h".}
  proc loadText*(path: cstring): cstring {.importc: "loadText", 
      header: "resource_loading.h".}
  proc loadImage*(filePath: cstring): ptr RawBitmapData {.importc: "loadImage", 
      header: "resource_loading.h".}

