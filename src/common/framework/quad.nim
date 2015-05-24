when not defined(H_QUAD_H): 
  const 
    H_QUAD_H* = true
  proc quadGlobalInit*() {.importc: "quadGlobalInit", header: "quad.h".}
  proc quadBeginFrame*() {.importc: "quadBeginFrame", header: "quad.h".}
  proc setTint*(r: cfloat; g: cfloat; b: cfloat) {.importc: "setTint", 
      header: "quad.h".}
  proc quadDrawCol*(x: cfloat; y: cfloat; width: cfloat; height: cfloat; 
                    red: cfloat; green: cfloat; blue: cfloat; alpha: cfloat; 
                    rot: cfloat; pivX: cfloat; pivY: cfloat) {.
      importc: "quadDrawCol", header: "quad.h".}
  proc quadFlush*() {.importc: "quadFlush", header: "quad.h".}
  proc quadEndFrame*() {.importc: "quadEndFrame", header: "quad.h".}
  proc getDrawCallCount*(): cint {.importc: "getDrawCallCount", header: "quad.h".}

