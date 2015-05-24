when not defined(PROFILE_H_7FNWFLPZ): 
  const 
    PROFILE_H_7FNWFLPZ* = true
  proc startProfiler*() {.importc: "startProfiler", header: "profiler.h".}
  proc stopProfiler*() {.importc: "stopProfiler", header: "profiler.h".}

