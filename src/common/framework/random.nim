when not defined(H_RANDOM): 
  const 
    H_RANDOM* = true
  proc randomSeed*(a2: cint) {.importc: "randomSeed", header: "random.h".}
  proc randomRandom*(): cint {.importc: "randomRandom", header: "random.h".}

