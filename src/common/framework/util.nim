when not defined(H_UTIL): 
  const 
    H_UTIL* = true
  proc trace*(msg: cstring) {.importc: "trace", header: "util.h".}
  proc traceNoNL*(msg: cstring) {.importc: "traceNoNL", header: "util.h".}
  proc traceInt*(a2: cint) {.importc: "traceInt", header: "util.h".}
  proc traceFmt*(fmt: cstring) {.varargs, importc: "traceFmt", header: "util.h".}

